(lang dune 3.20)

(name onion)

(generate_opam_files true)

(source
 (github super-nova-lang/onion))

(authors "Ashton Sickler <ashton.sickler06@gmail.com>")

(maintainers "Ashton Sickler <ashton.sickler06@gmail.com>")

(license MIT)


(package
 (name onion)
 (synopsis "Supernova Virtual Machine")
 (depends ocaml re)
 (tags
  ("supernova" "virtualmachine")))

