# Projet RTS 2020

**Sommaire:**
- 1. Manuel d'utilisation
- 2. Ordonnancement Rate Monotonic 
- 3. Ordonnancement Earliest Deadline First 

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


## Ordonnancement RM

## Ordonnancement EDF

### Caractéristiques

Le calcul de la priorité est dynamique: la tâche avec la date d'échéance la plus 
proche est la plus prioritaire.

Ordonnancement de trois types de tâches:
- **périodique:** c.f. ordonnancement RM.
- **apériodique:** tâche qui ne s'exécute qu'une unique.
- **sporadique:** tâche qui a une chance de se réveiller et dont le réveil 
doit attendre un délai minimal après que la tâche devienne prête.

### Mise en oeuvre

Champs du type `tcb`:
| Champs         | Description                                                | Périodique | Apériodique | Sporadique |
|----------------|------------------------------------------------------------|------------|-------------|------------|
| the_task       | Pointeur vers la tâche à exécuter                          | Oui        | Oui         | Oui        |
| period         | Période de la tâche                                        | Oui        | Non         | Non        |
| minimal_delay  | Délai minimum entre deux activation d'une tâche            | Non        | Non         | Oui        |
| next_execution | Prochaine date d'exécution de la tâche                     | Non        | Non         | Oui        |
| critical_delay | Délai critique de la tâche                                 | Oui        | Oui         | Oui        |
| start          | Date de début de la tâche                                  | Oui        | Oui         | Oui        |
| capacity       | Capacité de la tâche                                       | Oui        | Oui         | Oui        |
| nature         | Nature de la tâche (périodique, apériodique ou sporadique) | Oui        | Oui         | Oui        |
| status         | État de la tâche (en attente ou prête)                     | Oui        | Oui         | Oui        |

Structure du programme:
1. Élection de la tâche selon sa date d'échéance.
2. Lancement de la tâche
3. Vérification qu'aucune tâche n'a manqué son délai.
4. Passage au temps suivant.
5. Passer les tâches à prêtes:
   - Périodique: vérification que le temps courant est un multiple de la période.
   - Apériodique: vérification que le temps courant est égal au début de la tâche.
   - Sporadique: vérification que le temps courant est égal à la prochaine date 
   d'exécution et que la condition de probabilité de lancer la tâche est respectée
   (1/3 de chance dans l'implémentation).


### Tests

Il existe 3 tests pour cet ordonnanceur:
- le premier test ordonnance trois tâches de types différents.
- le deuxième test ordonnance trois tâches périodique qui utilisent 100% de la 
capacité du processeur.
- le troisième test tente d'ordonnancer trois tâches non ordonnançables.


**Test 1: `example_edf_1`**

Tâches:
- 1: périodique, début en 0, période de 10, capacité de 2 et délai critique de 10.
- 2: apériodique, début en 10, capacité de 4 et délai critique de 4.
- 3: sporadique, début en 5, délai minimal de 10, capacité de 8 et délai critique de 20.

Résultat obtenu:
|              |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
|:---:         |:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **TIME**     | 0   | 1   | 2   | 3   | 4   | 5   | 6   | 7   | 8   | 9   | 10  | 11  | 12  | 13  | 14  |15   |16   | 17  | 18  | 19  | 
| **TASKS**    | 1   | 1   |     |     |     | 3   | 3   | 3   | 3   | 3   | 2   | 2   | 2   | 2   | 1   | 1   | 3   | 3   | 3   |     | 
| **REALEASED**| 1   |     |     |     |     | 3   |     |     |     |     | 1,2 |     |     |     |     |     |     |     |     |     | 


**Test 2: `example_edf_2`**

Tâches:
- 1: périodique, début en 0, période de 10, capacité de 2 et délai critique de 10.
- 2: périodique, début en 0, période de 10, capacité de 4 et délai critique de 10.
- 3: périodique, début en 0, période de 20, capacité de 8 et délai critique de 20.

Résultat obtenu:
|              |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
|:---:         |:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **TIME**     | 0   | 1   | 2   | 3   | 4   | 5   | 6   | 7   | 8   | 9   | 10  | 11  | 12  | 13  | 14  |15   |16   | 17  | 18  | 19  | 
| **TASKS**    | 1   | 2   | 2   | 2   | 2   | 1   | 3   | 3   | 3   | 3   | 1   | 3   | 3   | 3   | 3   | 2   | 2   | 2   | 2   | 1   | 
| **REALEASED**|1,2,3|     |     |     |     |     |     |     |     |     | 1,2 |     |     |     |     |     |     |     |     |     | 


**Test 2: `example_edf_3`**

Tâches:
- 1: périodique, début en 0, période de 10, capacité de 9 et délai critique de 10.
- 2: apériodique, début en 10, capacité de 4 et délai critique de 4.
- 3: sporadique, début en 5, délai minimal de 10, capacité de 8 et délai critique de 20.

Résultat obtenu:
|              |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
|:---:         |:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **TIME**     | 0   | 1   | 2   | 3   | 4   | 5   | 6   | 7   | 8   | 9   | 10  | 11  | 12  | 13  | 14  |15   |16   | 17  | 18  | 19  |20   | 
| **TASKS**    | 1   | 1   | 1   | 1   | 1   | 1   | 1   | 1   | 1   | 3   | 2   | 2   | 2   | 2   | 1   | 1   | 3   | 3   | 3   |  3  |3    |
| **REALEASED**| 1   |     |     |     |     | 3   |     |     |     |     | 1,2 |     |     |     |     |     |     |     |     |     |     | 
| **MISSED**   |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |1    | 

