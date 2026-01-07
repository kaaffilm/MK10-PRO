"""Policy enforcement - law, not preference."""

from pathlib import Path
from typing import Dict, Any, List, Optional
import yaml

from engine.core.errors import PolicyError
from engine.evidence.recorder import EvidenceRecorder


class Policy:
    """
    Policy enforcement system.
    
    Policy is law. Configuration cannot override rules.
    """
    
    def __init__(
        self,
        rules_file: Optional[Path] = None,
        states_file: Optional[Path] = None,
    ):
        self.rules: List[Dict[str, Any]] = []
        self.states: List[Dict[str, Any]] = []
        self.transition_rules: List[Dict[str, Any]] = []
        
        if rules_file and rules_file.exists():
            self._load_rules(rules_file)
        if states_file and states_file.exists():
            self._load_states(states_file)
    
    def _load_rules(self, rules_file: Path) -> None:
        """Load policy rules from YAML."""
        with open(rules_file, "r") as f:
            data = yaml.safe_load(f)
            self.rules = data.get("rules", [])
    
    def _load_states(self, states_file: Path) -> None:
        """Load state definitions from YAML."""
        with open(states_file, "r") as f:
            data = yaml.safe_load(f)
            self.states = data.get("states", [])
            self.transition_rules = data.get("transition_rules", [])
    
    def check_rules(
        self,
        evidence: List[Dict[str, Any]],
        recorder: EvidenceRecorder,
    ) -> Dict[str, bool]:
        """
        Check all policy rules against evidence.
        
        Args:
            evidence: List of evidence events
            recorder: Evidence recorder for logging
            
        Returns:
            Dictionary mapping rule IDs to pass/fail status
            
        Raises:
            PolicyError: If strict enforcement and rule fails
        """
        results: Dict[str, bool] = {}
        
        for rule in self.rules:
            rule_id = rule["id"]
            passed = self._check_rule(rule, evidence)
            results[rule_id] = passed
            
            recorder.record_policy_check(
                rule_id=rule_id,
                passed=passed,
                details={"rule": rule},
            )
            
            if not passed and rule.get("severity") == "error":
                if self._is_strict():
                    raise PolicyError(f"Policy rule {rule_id} failed: {rule.get('name')}")
        
        return results
    
    def _check_rule(self, rule: Dict[str, Any], evidence: List[Dict[str, Any]]) -> bool:
        """Check a single rule."""
        check_type = rule.get("type")
        check_name = rule.get("check")
        
        if check_type == "evidence_check":
            return self._check_evidence(rule, evidence)
        elif check_type == "execution_check":
            return self._check_execution(rule, evidence)
        elif check_type == "lineage_check":
            return self._check_lineage(rule, evidence)
        elif check_type == "validation_check":
            return self._check_validation(rule, evidence)
        elif check_type == "integrity_check":
            return self._check_integrity(rule, evidence)
        else:
            # Unknown check type - fail in strict mode
            return not self._is_strict()
    
    def _check_evidence(self, rule: Dict[str, Any], evidence: List[Dict[str, Any]]) -> bool:
        """Check evidence-based rule."""
        evidence_type = rule.get("evidence_type")
        condition = rule.get("condition")
        
        relevant_events = [
            e for e in evidence
            if e.get("event_type") == evidence_type
        ]
        
        if not relevant_events:
            return False
        
        if condition:
            # Evaluate condition (simplified)
            return all(self._evaluate_condition(e, condition) for e in relevant_events)
        
        return len(relevant_events) > 0
    
    def _check_execution(self, rule: Dict[str, Any], evidence: List[Dict[str, Any]]) -> bool:
        """Check execution-based rule."""
        check_name = rule.get("check")
        
        if check_name == "deterministic_execution":
            # Check for execution_complete events
            complete_events = [
                e for e in evidence
                if e.get("event_type") == "execution_complete"
            ]
            return len(complete_events) > 0
        
        return True
    
    def _check_lineage(self, rule: Dict[str, Any], evidence: List[Dict[str, Any]]) -> bool:
        """Check lineage-based rule."""
        # Simplified - would check DAG completeness
        execution_events = [
            e for e in evidence
            if e.get("event_type") in ["execution_start", "node_execution", "execution_complete"]
        ]
        return len(execution_events) > 0
    
    def _check_validation(self, rule: Dict[str, Any], evidence: List[Dict[str, Any]]) -> bool:
        """Check validation-based rule."""
        validation_events = [
            e for e in evidence
            if e.get("event_type") == "validation"
        ]
        
        if not validation_events:
            return False
        
        # Check all validations passed
        return all(e.get("passed", False) for e in validation_events)
    
    def _check_integrity(self, rule: Dict[str, Any], evidence: List[Dict[str, Any]]) -> bool:
        """Check integrity-based rule."""
        check_name = rule.get("check")
        
        if check_name == "mtb_sealed":
            # Would check for seal event
            return True  # Simplified
        
        return True
    
    def _evaluate_condition(self, event: Dict[str, Any], condition: str) -> bool:
        """Evaluate condition string (simplified)."""
        # This is a simplified evaluator
        # In production, would use a proper expression evaluator
        if "==" in condition:
            parts = condition.split("==")
            key = parts[0].strip()
            value = parts[1].strip()
            return str(event.get(key)) == value
        return True
    
    def _is_strict(self) -> bool:
        """Check if strict enforcement is enabled."""
        return True  # Always strict - policy is law
    
    def can_transition(
        self,
        from_state: str,
        to_state: str,
        evidence: List[Dict[str, Any]],
    ) -> bool:
        """
        Check if state transition is allowed.
        
        Args:
            from_state: Current state
            to_state: Target state
            evidence: Evidence events
            
        Returns:
            True if transition is allowed
        """
        # Find state definition
        state_def = next(
            (s for s in self.states if s["id"] == from_state),
            None
        )
        
        if not state_def:
            return False
        
        # Find transition
        transition = next(
            (t for t in state_def.get("transitions", []) if t["to"] == to_state),
            None
        )
        
        if not transition:
            return False
        
        # Check requirements
        requires = transition.get("requires", [])
        for req_name in requires:
            req_rule = next(
                (r for r in self.transition_rules if r["name"] == req_name),
                None
            )
            
            if not req_rule:
                return False
            
            if not self._check_rule(req_rule, evidence):
                return False
        
        return True

