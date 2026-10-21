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

paper:
  typst compile --root ./papers/general/ --out ./papers/general/pdf/
  typst compile --root ./papers/maturita/ --out ./papers/maturita/pdf/

merge branch:
  git fetch origin {{branch}}
  git merge --squash origin/{{branch}}
  git commit --no-edit
  git push origin main

commit message:
  git commit -m "Commit time: {{time}} Created by: {{user}} Description: {{message}}"
