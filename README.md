# Projet RTS 2020

**Sommaire:**
- 1. Manuel d'utilisation
- 2. Ordonancement Rate Monotonic 
- 3. Ordonancement Earliest Deadline First 

[Énoncé du projet.](http://beru.univ-brest.fr/~singhoff/ENS/UE_temps_reel/TP-ADA/tp.html#Ref23)

## Manuel d'utilisation

**Prérequis:** `gnatmake`, `make`, `gcc`, environment unix.

**Structure:**
- **dossier *src*:** contient un dossier par ordonnanceur nommé *src[ORDONNANCEUR]* 
qui lui même contient le code source de cet ordonnanceur.
- **dossier *output*:** crée à la compilation, il contient l'ensemble des exécutables 
et possiblement leur traces d'exécution (voir `make log`).

**Commandes make:**
- **make:** compile chaque exécutable existant dans le projet.
- **make log:** compile chaque exécutable existant dans le projet et les exécute en redirigeant 
leur sortie standard dans un fichier.
- **make clean:** enlève l'ensemble des fichiers compilés et le répertoire *output*.

**Attention:** l'ensemble des commandes `make` sont à être exécutées à la racine du dossier.

**Exemple d'utilisation:**
```
$ make log
/* exécution des Makefile => compilation et exécution des exécutables générés */
$ ls output
example_edf_1      example_edf_2      example_edf_3      example_rm
example_edf_1.log  example_edf_2.log  example_edf_3.log  example_rm.log
```

**Note:**  
Lors de la compilation des exécutables d'un projet, deux messages 
sont attendus par ordonnanceur: `==> COMPILING example_[ORDONNANCEUR]` et 
`==> example_[ORDONNANCEUR] COMPILATION SUCCESFUL`. Si uniquement le premier 
est affiché, alors l'un des exécutables de l'ordonnanceur spécifié n'a pas 
été compilé.


## Ordonancement RM

## Ordonancement EDF


