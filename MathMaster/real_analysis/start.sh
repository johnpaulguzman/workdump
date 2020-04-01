#!/usr/bin/env bash

set -x
git pull
if [ -x "$(command -v evince)" ]; then
    viewer="evince"
else
    viewer="qpdfview"
fi

"${viewer}" __analysis.pdf &
#"${viewer}" rudin/RudinW.PrinciplesOfMathematicalAnalysis3e1976600Dpi.pdf &
#"${viewer}" dlsu/linear_algebra/smallpdf.com_la.pdf &
"${viewer}" dlsu/linear_algebra/LINEALGLEC1.pdf &
#"${viewer}" dlsu/linear_algebra/\(Undergraduate\ Texts\ in\ Mathematics\)\ Sheldon\ Axler\ \(auth.\)\ -\ Linear\ Algebra\ Done\ Right-Springer\ International\ Publishing\ \(2015\).pdf &
subl analysis.tex &
