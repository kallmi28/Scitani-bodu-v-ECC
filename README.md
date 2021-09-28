## Scitani bodu v ECC

### Implementacni platforma
Digilent Basys 3
### Popis chovani

Pripravek prijme ze seriove linky 40 B dat (2 body na elipticke krivce). Ty pak secte (pripadne odecte druhy od prvniho, pokud byl nastaven nejvyssi bit y souradnice druheho bodu) a vysledek vypise na sedmisegmentovy displej. Displej se posouva tlacitky nahoru (na vyssi 2 byty) a dolu (na nizsi 2 byty) na FPGA. Tlacitko uprostred slouzi pro reset. Zarizeni se musi resetovat pred prvnim pouzitim.

#### Zvlastnosti 

* Pro operaci 2P se musi zadat 2 stejne body. Zarizeni by melo byt schopne tuto operaci zvladnout i bez 2 stejnych bodu, ale z nejakeho duvodu si nezkopiruje prvni bod.

### Prilozene soubory

| Soubor        | Popis         |
| ------------- |:-------------:|
|[ecc.zip](https://gitlab.fit.cvut.cz/MI-BHW/B182/kallumir/blob/master/BHW4/ecc.zip)|archiv s projektem|
|[ecc_src.zip](https://gitlab.fit.cvut.cz/MI-BHW/B182/kallumir/blob/master/BHW4/ecc_src.zip)|archiv se zdrojovymi kody|
|[tb_top_ecc.sv](https://gitlab.fit.cvut.cz/MI-BHW/B182/kallumir/blob/master/BHW4/tb_top_ecc.sv)|testbench ecc jednotky|
|[top.bit](https://gitlab.fit.cvut.cz/MI-BHW/B182/kallumir/blob/master/BHW4/top.bit)|bitstream k nahrani|
