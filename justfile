_default:
    @just --list

check:
  nix flake check

update input:
  nix flake update {{input}}

build:
  nh os build .

switch:
  nh os switch .

deploy target:
  deploy -s .#{{target}}

paper:
  mkdir -p ./papers/general/pdf ./papers/maturita/pdf
  typst compile --root ./papers/general ./papers/general/main.typ ./papers/general/pdf/main.pdf
  typst compile --root ./papers/maturita ./papers/maturita/main.typ ./papers/maturita/pdf/main.pdf

paper-watch name="maturita":
  tinymist preview --open --root ./papers/{{name}} ./papers/{{name}}/main.typ

merge branch:
  git fetch origin {{branch}}
  git merge --squash origin/{{branch}}
  git commit --no-edit
  git push origin main
