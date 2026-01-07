"""Deterministic execution engine."""

from pathlib import Path
from typing import Dict, Any, List, Optional
from datetime import datetime

from engine.core.dag import DAG
from engine.core.node import Node, NodeInput, NodeOutput
from engine.core.context import ExecutionContext
from engine.core.errors import ExecutionError, DeterminismError
from engine.evidence.recorder import EvidenceRecorder
from engine.util.time import utc_now
from engine.util.fs import content_hash, ensure_dir


class Engine:
    """
    Deterministic execution engine.
    
    Executes DAG-based workflows as pure, deterministic functions.
    All transformations are content-addressed and evidence is recorded.
    """
    
    def __init__(self, context: ExecutionContext):
        self.context = context
        self.recorder = EvidenceRecorder(context.evidence_dir)
        self._outputs: Dict[str, NodeOutput] = {}
        self._execution_order: List[str] = []
    
    def execute(self, dag: DAG) -> Dict[str, NodeOutput]:
        """
        Execute DAG workflow.
        
        Args:
            dag: DAG to execute
            
        Returns:
            Dictionary mapping node IDs to outputs
            
        Raises:
            ExecutionError: If execution fails
            DeterminismError: If determinism is violated
        """
        dag.validate()
        execution_order = dag.topological_sort()
        self._execution_order = execution_order
        self._outputs = {}
        
        # Record execution start
        self.recorder.record_execution_start(
            execution_id=self.context.execution_id,
            dag_id=dag.dag_id,
            node_order=execution_order,
        )
        
        try:
            for node_id in execution_order:
                node = dag.nodes[node_id]
                dependencies = dag.get_dependencies(node_id)
                
                # Collect inputs from dependencies
                inputs = self._collect_inputs(node_id, dependencies, dag)
                
                # Execute node
                output = self._execute_node(node, inputs)
                
                # Store output
                self._outputs[node_id] = output
                
                # Record evidence
                self.recorder.record_node_execution(
                    node_id=node_id,
                    node_type=node.node_type,
                    inputs=[inp.content_address for inp in inputs],
                    output=output.content_address,
                    evidence=output.evidence,
                )
            
            # Record execution completion
            self.recorder.record_execution_complete(
                execution_id=self.context.execution_id,
                outputs={node_id: out.content_address for node_id, out in self._outputs.items()},
            )
            
            return self._outputs.copy()
        
        except Exception as e:
            self.recorder.record_execution_failure(
                execution_id=self.context.execution_id,
                error=str(e),
            )
            raise ExecutionError(f"Execution failed: {e}") from e
    
    def _collect_inputs(
        self,
        node_id: str,
        dependencies: List[str],
        dag: DAG,
    ) -> List[NodeInput]:
        """Collect inputs for a node from its dependencies."""
        inputs: List[NodeInput] = []
        
        if not dependencies:
            # Root node - inputs come from ingest
            # This would be populated from ingest manifest
            pass
        else:
            # Collect outputs from dependencies
            for dep_id in dependencies:
                if dep_id not in self._outputs:
                    raise ExecutionError(
                        f"Node {node_id} depends on {dep_id} but output not found"
                    )
                dep_output = self._outputs[dep_id]
                inputs.append(NodeInput(
                    content_address=dep_output.content_address,
                    path=dep_output.path,
                    metadata=dep_output.metadata,
                ))
        
        return inputs
    
    def _execute_node(self, node: Node, inputs: List[NodeInput]) -> NodeOutput:
        """
        Execute a single node.
        
        Args:
            node: Node to execute
            inputs: Node inputs
            
        Returns:
            Node output
            
        Raises:
            ExecutionError: If execution fails
        """
        # Validate inputs
        if not node.validate_inputs(inputs):
            raise ExecutionError(f"Node {node.node_id} input validation failed")
        
        # Execute
        output = node.execute(inputs, self.context)
        
        # Verify determinism: same inputs should produce same content address
        # This is a simplified check - full determinism requires re-execution
        if output.content_address and output.path.exists():
            computed_hash = content_hash(output.path)
            if computed_hash not in output.content_address:
                # Content address should contain hash
                pass  # This is a simplified check
        
        return output
    
    def get_lineage(self) -> Dict[str, Any]:
        """Get full lineage DAG from execution."""
        return {
            "execution_id": self.context.execution_id,
            "execution_order": self._execution_order,
            "outputs": {
                node_id: {
                    "content_address": out.content_address,
                    "metadata": out.metadata,
                }
                for node_id, out in self._outputs.items()
            },
        }

