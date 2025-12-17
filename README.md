# System Integration
## First Semester Exam
### December 2025 - January 2026

This is the repository containing the code project (Ymyzon),
the LaTeX files (main.tex, and contents of "out" directory),
the actual synopsis PDF (out/main.pdf),
and the scripts/workflows used to test and gather data for the synopsis.
### What have I done?
A .NET microservice application using RabbitMQ for messaging,
split into InventoryService and OrderService. 
For this project, several scripts have been written
(some surely redundant/improvable) to automate deployment
using Docker Compose, as well as to manually deploy the services.
Additionally, GitHub Actions workflows have been created
to automate deployment and measure performance in a proper
CI/CD environment.

### Repository Structure
- `Ymyzon/`: The main microservices application code.
- `.github/workflows/`: GitHub Actions workflows for CI/CD and performance measurement.
- `Ymyzon/Scripts/`: Bash scripts for deploying, testing, and comparing deployment methods.
- `out/`: LaTeX output files for the synopsis document, including the actual synopsis as main.pdf.
- `main.tex`: Main LaTeX file for the synopsis.
- `README.md`: This readme file. What, where did you think you were?
- `Ymyzon/RESULTS_SUMMARY.md`: A strange, AI-generated result summary. Mainly used as reference data for the synopsis.


### How to Use This Repository
1. Clone the repository to your local machine.
2. Navigate to the `Ymyzon/Scripts/` directory to find deployment and testing scripts.
3. Use the scripts to deploy the application manually or automatically.
4. Check the `.github/workflows/` directory for GitHub Actions workflows that automate CI/CD.
5. Refer to the `out/` directory for the synopsis document and related LaTeX files.

This should hopefully work, as a synopsis on the benefits of CI/CD
would be inflated real fast if I have to say
"well, it works on my machine!"