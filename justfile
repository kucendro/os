_default:
    @just --list

paper:
  typst compile --root ./papers/general/ --out ./papers/general/pdf/
  typst compile --root ./papers/maturita/ --out ./papers/maturita/pdf/
