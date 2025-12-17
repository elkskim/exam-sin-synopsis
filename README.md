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

## A Note on the Danish Translation - December 17th, 2025

This has been the subject of some frustration, 
and after speaking to my peers, and writing about
twenty expletives in this section,
I eventually let my anger condense into a small,
much funnier monologue. Enjoy.

### The Bureaucratic Labyrinth of Language Requirements

*[Lights cigarette with trembling hands]*

You see this? This `Danish_Translation/` directory? This is what happens when the administrative apparatus—
that great, grinding machine of forms and procedures—*finally* reveals its true nature. 
Not through malice, mind you. No, no. Through something far more insidious: 
*incompetent indifference*.

Every lecture? English. Every assignment? English. The synopsis template itself? 
*Beautifully* English. The very **guidelines** that tell you how to structure your thoughts? 
English, my friend. *All of it*. 

And yet—*and yet*—somewhere in the bowels of this institution, 
some functionary decided: "The final document? Ah yes, that must be in Danish."

Do you understand the dialectical contradiction here? The question posed in one tongue, 
the answer demanded in another? It's Kafkaesque. No—it's *beyond* Kafka. 
Even he would have rejected this as too on-the-nose.

I have placed the translation in its own directory. Not in a branch—oh no. 
A branch would suggest this decision deserves *organizational respect*. 
A separate directory is what it deserves: *segregation*. *Quarantine*. 
Like a document infected with bureaucratic madness.

Was there instruction for this? *Clear* instruction? Of course not. 
That would require the system to acknowledge its own absurdity. 
Instead, we divine the will of the institution like ancient priests reading entrails.

This is not personal. Not against any one teacher or administrator. 
They are merely—*we are all merely*—cogs in the machine. 
But by god, the machine is *broken*, and I'm sitting here at 2 AM translating 
my own work because apparently that's what passes for pedagogy now.

*[Takes long drag]*

You want the synopsis as it should be? The English version remains, unmolested by this farce, 
in `out/main.pdf`. You want to see what compliance with absurdity looks like? 
Check `Danish_Translation/out/main.pdf`. Either way, you're reading the same work—
just one version has been run through the bureaucratic meat grinder first.

*[Stares into middle distance]*

The future is already here. It's just in the wrong goddamn language.
