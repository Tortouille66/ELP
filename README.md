# Projet ELP

## Introduction

Ce dépôt contient le projet **ELP**.  
L’objectif du projet est d’explorer plusieurs langages de programmation, afin de comparer les approches, les contraintes techniques.

Le projet est organisé en trois sous-dossiers :
- ELP-JS
- ELP-GO
- ELP-ELM

Chaque sous-dossier correspond à son projet respectif.

---

## Organisation du dépôt

```text
.
├── ELP-JS/
├── ELP-GO/
└── ELP-ELM/
```

---

## ELP-JS

### Description

Le dossier **ELP-JS** contient l’implémentation du projet Flip7 en JavaScript, exécutée avec Node.js.  
Ce projet met en œuvre la reproduction en local du jeu de table Flip7.

### Prérequis

- Node.js

### Utilisation

```bash
cd ELP-JS/Flip7/
node src/index.js
```
### Jeu
---
Pour jouer vous devez suivre les consignes du terminal en indiquant le nombre de joueurs (2 à 4), le nom de chaque joueur puis jouer en tapant 1 ou 2 afin de tirer une carte ou s'arréter.

## ELP-GO

### Description

Le dossier **ELP-GO** contient l’implémentation d'une détection de contours par convulution.
### Image Edge Detection Server – Go

Ce projet implémente un serveur TCP concurrent en Go capable de détecter les contours d’une image à l’aide de filtres de convolution (Sobel).

Un client envoie une image (PNG/JPEG) au serveur, qui la convertit en niveaux de gris, applique une détection de contours, puis renvoie une image PNG contenant uniquement les bordures détectées.

Le projet met en œuvre la programmation concurrente en Go, un algorithme de traitement d’image et une communication client-serveur via TCP.

### TEST réalisé

La détéction de contour par convolution dépend d'un paramètre modifiable que l'on appelle seuil modifiable dans le fichier ELP-GO/server/tcp.go. Plus il est élevé plus le contour nécessite d'être net et inversement.

Nous avons réalisé plusieurs test dans le dossier ELP-GO/client/.


### Prérequis

- Go

### Utilisation

L'utilisation de ce programme est assez particulière car il faut dans un premier temps lancer le serveur TCP dans un premier terminal c'est à dire aller dans le dossier ELP-GO en effectuant ces commandes. 

```bash
cd ELP-GO
go run .
```

Ensuite après avoir enregistrer  votre image à contourer dans le bon format (PNG ou JPEG) et dans le bon dossier (client/). Il ne reste qu'à exécuter ces commandes dans un autre terminal. En sachant que image_à_contourer.png et votre image et contour.png sera le résultat de la détéction de contour par convolution. 

```bash
cd ELP-GO/client/
go run . <image_à_contourer>.png  <contour>.png
```

---

## ELP-ELM

### Description

Le dossier **ELP-ELM** contient l’implémentation d'un site Turtle Sans Ms (Référence à la police 'Comics Sans Ms') dont le but est de donner une intérface graphique simple pour effectuer des commandes Turtle (Langage de programmation Dessin).

### Prérequis

- Elm

### Utilisation

```bash
cd ELP-ELM
elm reactor
```

Puis ouvrir un navigateur à l’adresse indiquée (généralement `http://localhost:8000`) et sélectionner le fichier principal.

---

## Remarques

- Chaque sous-projet est indépendant.

- Le projet vise une comparaison entre plusieurs paradigmes de programmation.

---

## Auteurs

Projet réalisé dans le cadre du module **ELP** par LEVAL Enzo, MARTIN Ugo & DURAN Rémi
