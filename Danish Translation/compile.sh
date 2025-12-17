#!/bin/bash
# Compile Danish Translation to Danish Translation/out/
echo "Compiling Danish translation..."
cd "$(dirname "$0")"
pdflatex -interaction=nonstopmode -output-directory=out main.tex
cd out
biber main
cd ..
pdflatex -interaction=nonstopmode -output-directory=out main.tex
pdflatex -interaction=nonstopmode -output-directory=out main.tex
echo ""
echo "Danish PDF compiled to: Danish Translation/out/main.pdf"

