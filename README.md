## Test technique iOS Orange Prestations TV - OCS

Exercice de recrutement officiel d'Orange Prestations TV pour rejoindre le pôle de développeurs, réalisé par Koussaïla BEN MAMAR.

## Table des matières
- [Objectif](#objectif)
- [Test](#test)
- [Ma solution](#solution)

## <a name="objectif"></a>Objectif

Montrer sa capacité à créer, configurer et développer un mini-projet Swift avec Git.

En utilisant les API d'OCS (Orange Cinema Séries):
- Réaliser une petite interface de recherche de programmes.
- Afficher le détail d'un programme.
- Lancer une lecture d'un programme.

## <a name="test"></a>Test

1. L'interface utilisateur devra proposer un champ de recherche puis devra afficher sous forme de grille les différents programmes retournés par la requête API en résultat de recherche.

https://api.ocs.fr/apps/v2/contents?search=title

**Le titre ainsi que le sous-titre devront être affichés.**<br>
**Si une image est disponible pour le programme, elle devra être affichée.**

Ex d’appel : https://api.ocs.fr/apps/v2/contents?search=title%3DGame => le texte saisi par l’utilisateur est « Game »

2. Sur la **sélection d'un programme**, une nouvelle page devra afficher le détail du programme avec comme contenu:
- L'image en grand format : champ **`fullscreenimageurl`** récupéré lors de la recherche (si disponible).
- Un **bouton Play** sur l'image.
- Le titre du programme ou de la série : champ **`title`** récupéré lors de la recherche.
- Le sous-titre du programme ou de la série : champ **`subtitle`** récupéré lors de la
recherche.
- Le pitch du programme ou de la série : champ **`pitch`** (de la première saison disponible
dans le cas d'une série), récupéré via l'API **detaillink** (champ récupéré lors de la recherche).
+ Utilisation du **detaillink** : https://api.ocs.fr<detaillink>
Ex: https://api.ocs.fr/apps/v2/details/serie/PSGAMEOFTHRW0058624

3. Le tap sur le **bouton Play** devra lancer la lecture de la vidéo (voir lien ci-dessous), dans un player **AVPlayer** avec au minimum les fonctionnalités basiques d’un player (play, pause) :

https://bitmovin-a.akamaihd.net/content/bbb/stream.m3u8

### Contraintes

- Vous devrez utiliser le framework **Combine**
- L’interface doit être développée avec **UIKit**
- Vous devez utiliser les **storyboards** et **autolayout**
- Le projet doit respecter la compatibilité **iPhone**, **iPad**. **Apple TV** serait un plus.
- Le code doit être versionné sur **GitHub** ou **GitLab** et fonctionnel sur la branche **master**

### Dans cette exercice, nous serons attentifs à:
- La créativité
- La qualité dans le code
- Un choix d'architecture modulaire qui respecte le principe de responsabilité unique.
- La couverture des tests (unitaires et de bout en bout)

Imaginez votre application comme étant la base d'une application qui va évoluer (nouvelles fonctionnalités, nouveaux écrans, nouveaux webservice, ... ) au sein d'une équipe de plusieurs développeurs.

Bon courage et faites le maximum pour vous démarquer des autres candidats. Vous disposez <u>d'un délai d'une semaine</u> pour réaliser cet exercice.

Nous avons hâte de voir votre projet !

## <a name="solution"></a>Ma solution

Au niveau architecture modulaire, s'il faut respecter le principe de responsabilité unique (Single Responsibility), il est clair que **l'architecture la plus simple (et celle par défaut de UIKit) étant MVC est à bannir**. 

Moi même n'étant pas encore à l'aise avec les architectures les plus modulaires et les plus complexes (VIPER, Clean architecture,...), j'ai donc choisi l'architecture **MVVM** afin de respecter au mieux le principe de responsabilité unique et de permettre une meilleure couverture des tests (aussi du fait que c'est une architecture modulaire pas trop complexe pour les débutants).

**UIKit** étant obligatoire, avec les **Storyboards** et **Auto Layout**, il sont donc mis en place. **SwiftUI** reste l'alternative vu que cela requiert iOS 13, mais je n'en ai jamais fait. Pour le coup, je ne suis pas déstabilisé vu que j'ai commencé le développement iOS natif avec **UIKit** et **Storyboard** (cela serait plus difficile pour moi si les **Storyboards** et les **XIBs** étaient interdits).

Au niveau versionning, depuis le scandale raciste aux États-Unis lié au policier qui a provoqué la mort de George FLOYD (paix à son âme), GitHub a décidé par la suite de remplacer le nom de la branche principale **master** par **main**.

**Combine** est mis en place, l'interface est très fluide et dynamique lors de la recherche de contenu.

J'utilise aussi des frameworks tiers avec **Alamofire** pour la partie appels HTTP et **Kingfisher** pour la gestion asynchrone des images téléchargées avec le cache.

<<<<<<< HEAD
Concernant les tests, j'ai mis en place des tests unitaires (9 en tout) simulant des appels réseau par le biais du mocking et le tests des ViewModels. De même pour les tests UI. Les 9 tests unitaires couvrent **33,8%** du code, les tests UI couvrent **56,3%** du code, et exécutés ensemble, les tests unitaires et UI couvrent **61,8%** du code.
=======
Concernant les tests, j'ai mis en place des tests unitaires simulant des appels réseau par le biais du mocking et le tests des ViewModels. De même pour les tests UI.
>>>>>>> a2e0222110e4ab285a69fecd8d3a14ed7bdfdb40

### Difficultés rencontrées

- La mise en place du format grille à 2 colonnes pour iPhone et iPad avec le `CollectionView`.
- Auto Layout notamment pour les Size Classes afin d'adapter la vue pour l'iPhone et l'iPad.
- L'API OCS qui est complexe pour la mise en place des modèles et particulièrement le modèle du programme en détail (pouvant varier si c'est un film, une série ou une émission).
- Les liens des images par le biais du nom de domaine `https://api.ocs.fr/` qui renvoie le code 503. Une investigation par inspection du code HTML est nécessaire pour récupérer le nom de domaine (ici `https://statics.ocs.fr/`)qui permet de télécharger les images par les liens récupérés de la réponse JSON de l'API REST.
<<<<<<< HEAD
- La mise en place de la programmation réactive fonctionnelle avec **Combine** (framework officiel d'Apple). iOS 13 est donc requis pour utiliser **Combine**, **RxSwift** sinon. Avec **UIKit**, la mise en place de **Combine** est compliquée au début, n'ayant jamais utilisé ce framework (ni **RxSwift** par ailleurs). De plus, les ressources pour apprendre **Combine** et les appliquer avec **UIKit** sont très limitées (notamment pour le cas des **TableView** et **CollectionView**), la grande majorité des ressources sont orientées **SwiftUI** vu que **Combine** est adpaté.
- La couverture du code par les tests (unitaires et UI) et la gestion des appels asynchrones (avec Combine) lors des tests.
=======
- La mise en place de la programmation réactive fonctionnelle avec **Combine** (framework officiel d'Apple). iOS 13 est donc requis pour utiliser **Combine**, **RxSwift** sinon. Avec **UIKit**, la mise en place de **Combine** est compliquée au début, n'ayant jamais utilisé ce framework (ni **RxSwift** par ailleurs), 
- La couverture du code par les tests (unitaires et UI). Les ressources pour apprendre et appliquer **Combine** avec UIKit sont très limités sur Internet ce qui justifie la difficulté d'implémentation, les ressources sont majoritairement orientés **SwiftUI**.
>>>>>>> a2e0222110e4ab285a69fecd8d3a14ed7bdfdb40
- La mise en place du lecteur **`AVPlayer`**. S'il faut tout personnaliser, c'est compliqué. J'ai donc utilisé un `AVPlayerViewController` pour la partie lecture vidéo par le biais d'HTTP Live Streaming.
- Je ne dispose pas de compte Apple Developer payant (enregistré à l'Apple Developer Program).
