.PHONY: install test clean verify format lint

install:
	pip install -e .

test:
	pytest tests/ -v

clean:
	find . -type d -name __pycache__ -exec rm -r {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type d -name "*.egg-info" -exec rm -r {} + 2>/dev/null || true
	rm -rf .cache .workspace evidence *.mtb *.mtb.zip

verify:
	python -m verifier.verify_mtb verifier/examples/sample_mtb.zip

format:
	black engine/ mtb/ verifier/ cli/ tests/
	isort engine/ mtb/ verifier/ cli/ tests/

lint:
	flake8 engine/ mtb/ verifier/ cli/ tests/
	mypy engine/ mtb/ verifier/ cli/

setup:
	python -m venv venv
	. venv/bin/activate && pip install -r requirements.txt

