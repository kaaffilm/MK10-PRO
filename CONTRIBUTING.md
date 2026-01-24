# Contributing to MK10-PRO

## Before You Start

MK10-PRO is a **deterministic truth infrastructure** for audiovisual mastering. Changes to verification semantics require extraordinary scrutiny.

### What Will Be Accepted

- **Documentation improvements**: Clarifications, typo fixes, examples
- **Test coverage**: Additional test cases that don't modify behavior
- **Bug fixes**: With clear reproduction steps and tests
- **Security fixes**: Via private disclosure (see SECURITY.md)

### What Will Be Rejected

- Changes to MTB schema without spec update
- Changes that break determinism guarantees
- Features that bypass policy enforcement
- "Improvements" that alter hash computation
- PRs without tests for behavioral changes

## Development Setup

```bash
# Clone the repository
git clone https://github.com/kaaffilm/MK10-PRO.git
cd MK10-PRO

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
pip install -e .
```

## Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=.

# Run specific test
pytest tests/test_determinism.py
```

## Pull Request Process

### For Documentation Changes

1. Fork the repository
2. Create a branch: `docs/your-change`
3. Make changes
4. Submit PR with label `docs-only`

### For Code Changes

1. Fork the repository
2. Create a branch: `fix/issue-number` or `feature/description`
3. Write tests first
4. Make changes
5. Ensure all tests pass
6. Submit PR

**Code PRs require:**
- Passing CI
- At least one approval
- No unresolved conversations

### For Schema/Verification Changes

1. Open an issue first describing the change
2. Wait for explicit approval before starting work
3. Update specification document
4. Write comprehensive tests
5. Submit PR with label `contract-change`

## Code Style

- Follow PEP 8
- Use type hints
- Document public functions
- Keep functions focused and small

## Commit Messages

```
<type>: <description>

[optional body]
```

Types:
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Test changes
- `refactor`: Code refactoring (no behavior change)
- `feat`: New feature (requires discussion)
