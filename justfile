_default:
    @just --list

paper:
  typst compile --root ./papers/general/ --out ./papers/general/pdf/
  typst compile --root ./papers/maturita/ --out ./papers/maturita/pdf/

merge branch:
  git fetch origin {{branch}}
  git merge --squash origin/{{branch}}
  git commit --no-edit
  git push origin main
