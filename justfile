time := datetime_utc("%Y%m%dT%H%M%SZ")
user := env('USER', 'unidentified')

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

paper: (_paper "general") (_paper "maturita")

_paper name:
  mkdir -p ./papers/{{name}}/pdf
  typst compile --root ./papers/{{name}} ./papers/{{name}}/main.typ ./papers/{{name}}/pdf/main.pdf
  typst compile --root ./papers/{{name}} --format png --pages 1 --ppi 40 ./papers/{{name}}/main.typ ./papers/{{name}}/pdf/preview.png

paper-watch name="maturita":
  tinymist preview --open --root ./papers/{{name}} ./papers/{{name}}/main.typ

merge branch:
  git fetch origin {{branch}}
  git merge --squash origin/{{branch}}
  git commit --no-edit
  git push origin main


maturita message:
  git commit -m "[MATURITA - SPSE]: {{message}}"
