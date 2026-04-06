!(import! &self state)
!(import! &self signals)
!(import! &self policy)
!(import! &self bridge)
!(import! &self update)

!(import! &self (library lib lib_import))
!(git-import! "https://github.com/patham9/mettaclaw.git")
!(import! &self (library mettaclaw lib_mettaclaw))


!(motivated-mettaclaw)
