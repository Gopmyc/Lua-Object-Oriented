### **1. Introduction à la POO**
La **Programmation Orientée Objet** repose sur l’idée de structurer le code autour d’entités appelées "objets". Chaque objet est une instance d'une **classe**, et contient des **propriétés** et des **méthodes** qui définissent son comportement et son état.

- **Classe** : une structure qui définit un modèle ou un prototype pour les objets.
- **Objet** : une instance concrète d’une classe.
- **Méthode** : une fonction définie au sein d’une classe.
- **Propriété** : une variable associée à un objet.

Bien que **Lua** ne dispose pas d’un mécanisme natif pour la POO comme d’autres langages (Java, Python, C++), il est tout à fait possible de simuler ce paradigme à l’aide de **tables** et **métatables**.

### **2. Créer une Classe en Lua**
La première étape pour implémenter la POO en Lua consiste à créer une **classe**, qui sera simplement une table Lua à laquelle on ajoutera des méthodes.

#### Exemple : Création d'une classe "Voiture"
```lua
-- Définir la classe "Voiture"
Voiture = {}
Voiture.__index = Voiture

-- Constructeur de la classe Voiture
function Voiture.new(marque, couleur)
    local self = setmetatable({}, Voiture)
    self.marque = marque
    self.couleur = couleur
    return self
end

-- Méthode pour démarrer la voiture
function Voiture:demarrer()
    print(self.marque .. " démarre !")
end

-- Méthode pour afficher les informations de la voiture
function Voiture:afficherInfo()
    print("Marque: " .. self.marque .. ", Couleur: " .. self.couleur)
end
```

**Explications** :  
- **Voiture = {}** : Nous définissons la classe `Voiture` comme une table vide.
- **Voiture.__index = Voiture** : Cette ligne configure `Voiture` comme le prototype d'objet pour la recherche de méthodes via `self`.
- **Voiture.new** : La fonction `new` sert de constructeur. Elle crée un nouvel objet de type `Voiture` avec les propriétés définies et l’associe à la métatable `Voiture`.
- **self** : En Lua, `self` fait référence à l’instance courante de l’objet, ce qui nous permet d’accéder à ses propriétés et méthodes.

### **3. Héritage en Lua**
Lua permet de mettre en œuvre l'héritage en utilisant des métatables. Une **classe enfant** peut hériter d'une **classe parente** et accéder aux méthodes de cette dernière, tout en étant capable de redéfinir ou d'étendre ces méthodes.

#### Exemple : Héritage avec "VoitureDeCourse"
```lua
-- Classe "VoitureDeCourse" héritant de "Voiture"
VoitureDeCourse = setmetatable({}, Voiture)
VoitureDeCourse.__index = VoitureDeCourse

-- Constructeur de la classe VoitureDeCourse
function VoitureDeCourse.new(marque, couleur, vitesseMax)
    local self = setmetatable(Voiture.new(marque, couleur), VoitureDeCourse)
    self.vitesseMax = vitesseMax
    return self
end

-- Redéfinition de la méthode "demarrer"
function VoitureDeCourse:demarrer()
    print(self.marque .. " démarre avec une vitesse max de " .. self.vitesseMax .. " km/h !")
end
```

**Explications** :  
- **VoitureDeCourse = setmetatable({}, Voiture)** : La classe `VoitureDeCourse` hérite des méthodes de la classe `Voiture` via la métatable.
- **setmetatable(Voiture.new(...), VoitureDeCourse)** : Nous appelons le constructeur de la classe parente (`Voiture.new`) et associons l’objet à la classe enfant `VoitureDeCourse`.
- **Redéfinition de `demarrer`** : La méthode `demarrer` de `VoitureDeCourse` surcharge celle de `Voiture` pour y ajouter des fonctionnalités spécifiques.

### **4. Encapsulation et Accesseurs**
L’encapsulation permet de protéger les données internes d’un objet et de n’en exposer l’accès que par des méthodes spécifiques (accesseurs). En Lua, cela peut être géré en combinant des propriétés privées et publiques.

#### Exemple d'encapsulation avec "Personne"
```lua
Personne = {}
Personne.__index = Personne

function Personne.new(nom, age)
    local self = setmetatable({}, Personne)
    self._nom = nom  -- Propriété privée
    self._age = age  -- Propriété privée
    return self
end

-- Accesseur pour le nom
function Personne:getNom()
    return self._nom
end

-- Accesseur pour l'âge
function Personne:getAge()
    return self._age
end
```

**Explications** :  
- **self._nom** et **self._age** : Ces propriétés sont considérées comme privées par convention (elles sont préfixées par un `_`).
- **getNom() et getAge()** : Ces méthodes permettent d'accéder aux valeurs des propriétés privées.

### **5. Abstraction**
L’abstraction consiste à masquer les détails d’implémentation d’un objet tout en exposant une interface simplifiée. Cela permet aux développeurs d'interagir avec des objets sans avoir besoin de connaître leur fonctionnement interne.

En Lua, l’abstraction est réalisée par les méthodes publiques qui interagissent avec des propriétés privées ou protégées. Cela permet de contrôler l’accès aux données internes de manière sécurisée.

#### Exemple d'abstraction avec "CompteBancaire"
```lua
CompteBancaire = {}
CompteBancaire.__index = CompteBancaire

-- Constructeur
function CompteBancaire.new(solde)
    local self = setmetatable({}, CompteBancaire)
    self._solde = solde
    return self
end

-- Méthode d'abstraction : dépôt
function CompteBancaire:deposer(montant)
    if montant > 0 then
        self._solde = self._solde + montant
    else
        print("Montant invalide")
    end
end

-- Méthode d'abstraction : retrait
function CompteBancaire:retirer(montant)
    if montant > 0 and montant <= self._solde then
        self._solde = self._solde - montant
    else
        print("Retrait impossible")
    end
end

-- Méthode d'accès au solde
function CompteBancaire:getSolde()
    return self._solde
end
```

**Explications** :  
- Les utilisateurs de `CompteBancaire` ne connaissent pas la manière dont le solde est stocké. Ils interagissent uniquement avec des méthodes comme `deposer`, `retirer`, et `getSolde` qui cachent la logique interne du compte.
- Cela permet d’éviter que des parties externes du programme manipulent directement le solde, assurant ainsi un meilleur contrôle.

### **6. Polymorphisme**
Le **polymorphisme** permet à différentes classes d'être traitées de manière uniforme, même si elles ont des implémentations différentes. En pratique, le polymorphisme permet de redéfinir une méthode dans une classe enfant tout en la réutilisant dans une classe parente.

Le polymorphisme peut être statique (lorsque l’on surcharge des méthodes) ou dynamique (lorsque l’on utilise des objets de types différents mais ayant une interface commune).

#### Exemple de polymorphisme dynamique avec "Animal" et "Chien"
```lua
-- Classe de base : Animal
Animal = {}
Animal.__index = Animal

function Animal.new(nom)
    local self = setmetatable({}, Animal)
    self.nom = nom
    return self
end

function Animal:faireDuBruit()
    print(self.nom .. " fait un bruit !")
end

-- Classe dérivée : Chien
Chien = setmetatable({}, Animal)
Chien.__index = Chien

function Chien.new(nom)
    local self = setmetatable(Animal.new(nom), Chien)
    return self
end

function Chien:faireDuBruit()
    print(self.nom .. " aboie !")
end

-- Classe dérivée : Chat
Chat = setmetatable({}, Animal)
Chat.__index = Chat

function Chat.new(nom)
    local self = setmetatable(Animal.new(nom), Chat)
    return self
end

function Chat:faireDuBruit()
    print(self.nom .. " miaule !")
end

-- Exemple de polymorphisme dynamique
local animaux = { Animal.new("Animal générique"), Chien.new("Rex"), Chat.new("Miaou") }

for _, animal in ipairs(animaux) do
    animal:faireDuBruit()  -- Chaque animal appelle sa méthode redéfinie
end
```

**Explications** :  
- Les méthodes de chaque classe enfant (`Chien` et `Chat`) redéfinissent la méthode `faireDuBruit()` de la classe parente `Animal`.
- Lors de l'itération sur les objets, même si on utilise des objets de types différents (Animal, Chien, Chat), la méthode correcte est appelée grâce au polymorphisme.

### **7. Interface et Protocoles (Concept Abstrait)**
Une **interface** en POO est un contrat qui définit un ensemble de méthodes que les classes doivent implémenter. Bien que Lua ne supporte pas directement les interfaces comme dans des langages comme Java, il est possible de simuler ce comportement.

En Lua, les interfaces peuvent être représentées par des tables avec des méthodes attendues, mais chaque classe doit s’assurer de les implémenter correctement.

#### Exemple de simulation d'interface
```lua
-- "Interface" définit une méthode qu'une classe doit implémenter
InterfaceAction = {}
InterfaceAction.__index = InterfaceAction

function InterfaceAction:agir()
    error("La méthode agir doit être implémentée")
end

-- Classe qui implémente l'interface
Personnage = setmetatable({}, InterfaceAction)
Personnage.__index = Personnage

function Personnage.new(nom)
    local self = setmetatable({}, Personnage)
    self.nom = nom
    return self
end

function Personnage:agir()
    print(self.nom .. " agit de manière spécifique.")
end
```

**Explications** :  
- **InterfaceAction** définit une méthode `agir()` que toutes les classes implémentant cette interface devront définir.
- Si une classe ne définit pas cette méthode, une erreur est levée.
  
Cela permet de garantir que toutes les classes qui veulent implémenter une "interface" respectent un contrat spécifique.

### **8. Destructeurs et Finalisation d'Objets**
En POO, un **destructeur** est une méthode appelée lorsqu'un objet est détruit ou finalisé. En Lua, ce processus peut être simulé à l’aide de la métaméthode `__gc`, qui est automatiquement appelée lors de la collecte des ordures (garbage collection).

#### Exemple d'un destructeur
```lua
Personne = {}
Personne.__index = Personne

-- Constructeur
function Personne.new(nom, age)
    local self = setmetatable({}, Personne)
    self.nom = nom
    self.age = age
    return self
end

-- Destructeur
function Personne:__gc()
    print(self.nom .. " est détruit !")
end

-- Exemple d'utilisation
local p = Personne.new("Jean", 30)
p = nil  -- Le collecteur d'ordures appellera __gc
collectgarbage()  -- Force la collecte des ordures
```

**Explications** :  
- La méthode `__gc` est utilisée pour simuler un destructeur, permettant de gérer des tâches de nettoyage avant qu'un objet ne soit détruit.

### **9. Concepts Avancés de la POO en Lua**

Dans cette section, nous allons explorer des concepts plus avancés de la programmation orientée objet (POO) en Lua. Ces notions vont au-delà des bases et permettent de rendre le code plus modulaire, flexible et facile à maintenir. 

---

#### **9.1 Métatables et Métaprogrammation**

Lua offre un puissant mécanisme appelé **métatables** qui permet de modifier le comportement par défaut des tables. C'est grâce à elles qu'on peut simuler l'héritage, la surcharge des opérateurs, ou même implémenter des méthodes comme `__call`, `__index`, et `__gc`.

Par exemple, on peut définir un opérateur `__add` pour permettre l'addition de deux objets d'une classe :

```lua
MonObjet = {}
MonObjet.__index = MonObjet

-- Surcharge de l'opérateur d'addition
function MonObjet.__add(o1, o2)
    return MonObjet.new(o1.valeur + o2.valeur)
end

function MonObjet.new(valeur)
    local self = setmetatable({}, MonObjet)
    self.valeur = valeur
    return self
end

-- Utilisation de l'addition
local obj1 = MonObjet.new(5)
local obj2 = MonObjet.new(10)
local obj3 = obj1 + obj2
print(obj3.valeur)  -- Affiche 15
```

**Concept à retenir** : Les métatables permettent de personnaliser le comportement d'objets et de tables en Lua, ce qui rend le langage particulièrement flexible pour la POO.

#### **9.2 Accesseurs avec Validation des Types**

Les **accesseurs** (getters/setters) peuvent être enrichis pour **valider les types** des données avant de les assigner ou de les récupérer. Cela peut garantir que les données sont toujours dans un format correct et éviter des erreurs à runtime.

Voici un exemple d'accesseurs avec validation de types dans un objet :

```lua
Types = {
    FORCE_STRING = 1,
    FORCE_NUMBER = 2,
    FORCE_BOOL = 3,
}

-- Définition des accesseurs
function Personne:registerAccessor(varName, name, forceType, defaultValue)
    self["Get" .. name] = function(self)
        return self.__private[varName]
    end

    local setters = {
        [Types.FORCE_STRING] = function(self, value)
            self.__private[varName] = value and tostring(value) or defaultValue
        end,
        [Types.FORCE_NUMBER] = function(self, value)
            self.__private[varName] = value and tonumber(value) or defaultValue
        end,
        [Types.FORCE_BOOL] = function(self, value)
            self.__private[varName] = value and tobool(value) or defaultValue
        end
    }

    self["Set" .. name] = setters[forceType] or function(self, value)
        self.__private[varName] = value or defaultValue
    end
end
```

Ici, les valeurs sont forcées à un type spécifique (comme **STRING**, **NUMBER**, ou **BOOL**) avant d'être assignées à une propriété privée.

**Concept à retenir** : L'utilisation de **setters et getters avancés avec validation** permet de contrôler et garantir l'intégrité des données.

### **9.3 Héritage Avancé et la Fonction `super()`**

L’héritage en Lua repose sur les métatables. Dans des cas plus complexes, il peut être nécessaire d’appeler des méthodes d'une classe parente depuis une classe enfant tout en conservant la flexibilité du code. La fonction **`super()`** simplifie l'appel des méthodes parentes dans une hiérarchie plus poussée.

Lors de la redéfinition de méthodes, on peut vouloir accéder à la méthode de la classe parente sans perdre la possibilité d’ajouter un comportement spécifique dans l’enfant.

#### Exemple : Utilisation de `super()` pour appuyer une méthode parente

```lua
-- Classe Parent
Parent = {}
Parent.__index = Parent

function Parent:new(name)
    local self = setmetatable({}, Parent)
    self.name = name
    return self
end

function Parent:hello() print("Hello from Parent: " .. self.name) end

-- Classe Enfant
Child = setmetatable({}, Parent)
Child.__index = Child

function Child:new(name)
    return setmetatable(Parent.new(self, name), Child)
end

function Child:hello()
    Parent.hello(self)
    print("Hello from Child: " .. self.name)
end

-- Utilisation
local child = Child:new("John")
child:hello()
```

#### Explication :
- **Appel explicite** : Dans `hello()` de `Child`, l’appel à `Parent.hello(self)` permet d’exécuter la méthode de la classe parente avant d'ajouter la fonctionnalité de l’enfant.
- **Utilisation de `super()`** : Lua ne possède pas directement un mot-clé `super`, mais l'appel explicite à la méthode parente est une pratique courante.

#### Exemple de fonction `super()` personnalisée :

```lua
function super(self, methodName, ...)
    local parentMethod = getmetatable(self)[methodName]
    if parentMethod then
        return parentMethod(self, ...)
    else
        error("Méthode " .. methodName .. " introuvable dans la classe parente")
    end
end

-- Classe Enfant avec super()
function Child:hello()
    super(self, "hello")
    print("Hello from Child: " .. self.name)
end
```

#### **9.4 Clonage d'Objets**

Il est parfois utile de créer une **copie d'un objet** tout en conservant sa structure interne et ses métadonnées. En Lua, cela peut être réalisé via la fonction `clone()`, qui copie à la fois les métatables et les propriétés de l'objet.

```lua
-- Fonction de clonage
function clone(obj)
    local copy = setmetatable({}, getmetatable(obj))
    for k, v in pairs(obj) do
        copy[k] = v
    end
    return copy
end

local original = {name = "Mon Objet", value = 42}
local cloneObj = clone(original)
print(cloneObj.name)  -- Affiche "Mon Objet"
```

**Concept à retenir** : Le **clonage d'objets** permet de créer des copies d’objets tout en maintenant les métatables et les comportements associés.

#### **9.5 Encapsulation Avancée (Propriétés Privées)**

Dans le code avancé, les objets peuvent avoir des **propriétés privées** protégées par des méthodes spécifiques. Cela garantit que les données sensibles ou internes ne peuvent pas être directement modifiées, mais seulement à travers des méthodes définies.

```lua
local MonObjet = {}
MonObjet.__index = MonObjet

function MonObjet:new()
    local self = setmetatable({}, MonObjet)
    self.__private = {}  -- Propriétés privées
    return self
end

function MonObjet:setPrivateData(value)
    self.__private.data = value
end

function MonObjet:getPrivateData()
    return self.__private.data
end
```

**Concept à retenir** : **L'encapsulation avancée** permet de protéger les données privées des objets en les stockant dans des tables séparées (comme `__private`) et en les accédant via des méthodes spécifiques.

#### **9.6 Héritage Multiple et Inclusion Dynamique**

Parfois, il peut être nécessaire de combiner plusieurs classes dans un seul objet. En Lua, cela peut être accompli en utilisant une fonction d'**inclusion dynamique**, ce qui permet de combiner des méthodes et des propriétés provenant de plusieurs classes.

```lua
-- Inclusion de classes
function include(class, other)
    for k, v in pairs(other) do
        if not class[k] then
            class[k] = v
        end
    end
end

-- Classes
ClassA = {propertyA = "A"}
ClassB = {propertyB = "B"}

-- Objet combiné
Combined = {}
include(Combined, ClassA)
include(Combined, ClassB)

print(Combined.propertyA)  -- Affiche "A"
print(Combined.propertyB)  -- Affiche "B"
```

**Concept à retenir** : **L'héritage multiple et l'inclusion dynamique** permettent de fusionner des propriétés et des méthodes de plusieurs classes dans un objet, offrant ainsi une grande flexibilité.

#### **9.7 Gestion de la Mémoire et Destructeurs**

En Lua, la gestion de la mémoire est automatique grâce au **ramasse-miettes** (garbage collector), mais parfois, on souhaite exécuter des actions spécifiques avant qu'un objet ne soit détruit (par exemple, libérer des ressources). Cela peut être réalisé avec la fonction **`__gc`**.

```lua
MyClass = {}
MyClass.__index = MyClass

function MyClass:new()
    local self = setmetatable({}, MyClass)
    self.value = 42
    return self
end

function MyClass:__gc()
    print("MyClass instance is being collected!")
end

-- Exemple d'utilisation
local obj = MyClass:new()
obj = nil  -- Le ramasse-miettes appelle automatiquement __gc ici
collectgarbage()  -- Force la collecte des ordures
```

**Concept à retenir** : Le **destructeur (`__gc`)** permet de gérer proprement la destruction des objets et de libérer les ressources.

### **Conclusion**

Dans ce tutoriel, nous avons exploré les principes fondamentaux de la Programmation Orientée Objet (POO) en Lua, un langage qui, bien qu'il ne supporte pas la POO de manière native, permet néanmoins de simuler de manière très flexible et puissante ce paradigme via des tables et des métatables.

Nous avons abordé les concepts clés tels que la création de classes, l'héritage, l'encapsulation, l'abstraction, le polymorphisme, et bien plus encore, tout en illustrant chaque concept par des exemples concrets. En Lua, la POO est très modulaire et flexible, permettant de structurer le code de manière plus lisible, réutilisable et maintenable, même dans un environnement sans support direct de classes et d'objets comme dans d'autres langages.

Pour aller plus loin dans l'application de ces concepts, vous pouvez consulter le fichier [**'class.lua'**](class.lua), qui fait office d'exemple pour voir comment tous ces concepts peuvent être intégrés dans une application plus complète et fonctionnelle.

Cela vous permettra d’avoir une meilleure compréhension pratique et d'expérimenter vous-même la puissance de la POO en Lua dans vos projets.
Le script est regie par la license **GPL-3.0**.

Class.lua :

```lua

-------------------------------------------------------------------
--- 'Class' system inspired by the 'Matthias Richter' system.   ---
--- ('https://github.com/vrld/hump/blob/master/class.lua')      ---
-------------------------------------------------------------------

return function(...)
    local tTypes    =   {
        ["FORCE_STRING"]    =   FORCE_STRING    or  1,
        ["FORCE_NUMBER"]    =   FORCE_NUMBER    or  2,
        ["FORCE_BOOL"]      =   FORCE_BOOL      or  3,
    }

    local function includeHelper(tClass, tOther, tSeen)
        if tOther == nil then return tClass end
        if type(tOther) ~= 'table' then return tOther end
        if tSeen[tOther] then return tSeen[tOther] end
    
        tSeen[tOther] = tClass
        for k, v in pairs(tOther) do if not tSeen[k] then tClass[k] = includeHelper({}, v, tSeen) end end

        return tClass
    end    

    local function debugInfo(tSelf)
        local tMt = type(tSelf) == "userdata" and getmetatable(tSelf) or tSelf
        assert(tMt, "Object has no metatable!")
    
        local tStr = {
            "==========================",
            "=== DEBUG OBJECT INFO ===",
            "==========================",
            "\nType: " .. (tMt.__type or "Unknown"),
            "\n# Private Data:",
        }

        table.insert(tStr, (tMt.__private and table.concat({table.unpack(tMt.__private, function(k, v) return string.format("  - %s = %s", k, tostring(v)) end)}, "\n") or "  (empty)"))
        table.insert(tStr, "\n# Methods:")
        table.insert(tStr, table.concat((function() local methods = {} for k, v in pairs(tMt) do if type(v) == "function" then table.insert(methods, string.format("  - %s type : %s", k, type(v))) end end return methods end)(), "\n"))
    
        table.insert(tStr, "\n==========================")
        return table.concat(tStr, "\n")
    end
    

    local function accessor(tSelf, tVarName, tName, tIForce, tDefaultValue)
        tSelf["Get" .. tName] = function(tSelf) return tSelf.__private[tVarName] end

        local tSetters = {
            [tTypes["FORCE_STRING"]] = function(tSelf, tV) tSelf.__private[tVarName] = tV ~= nil and tostring(tV) or tDefaultValue end,
            [tTypes["FORCE_NUMBER"]] = function(tSelf, tV) tSelf.__private[tVarName] = tV ~= nil and tonumber(tV) or tDefaultValue end,
            [tTypes["FORCE_BOOL"]] = function(tSelf, tV) tSelf.__private[tVarName] = tV ~= nil and (tV == nil || tV == false || tV == 0 || tV == "0" || tV == "false") and false or true or tDefaultValue end,
        }

        tSelf["Set" .. tName] = tSetters[tIForce] or function(tSelf, tV) tSelf.__private[tVarName] = tV ~= nil and tV or tDefaultValue end
    end

    local function include(tClass, tOther) return includeHelper(tClass, tOther, {}) end
    local function clone(tOther) return setmetatable(include({}, tOther), assert(getmetatable(tOther), "Cannot clone an object without a metatable.")) end
    local function super(tSelf, tMethod, ...) if tSelf.__super and tSelf.__super[tMethod] then return tSelf.__super[tMethod](tSelf, ...) else error("Method " .. tMethod .. " not found in parent class.") end end
    
    local function new(tClass)
        tClass                  =   tClass or {}
        local tInc              =   getmetatable(tClass.__includes) and {tClass.__includes} or tClass.__includes or {}

        for _, tOther in ipairs(tInc) do if type(tOther) == "string" then tOther = _G[tOther] end include(tClass, tOther) end

        tClass.__index          =   tClass
        tClass.__super          =   tClass.__super or nil
        tClass.__type           =   tClass.__type or "Class"

        tClass.__privateMethods =   tClass.__privateMethods or {}

        local tMethodsToHide    =   {
            init        =   tClass.init    or tClass[1] or function() end,
            include     =   tClass.include or include,
            clone       =   tClass.clone   or clone,
            DebugInfos  =   tClass.__privateMethods.DebugInfos or debugInfo,
        }

        for k, v in pairs(tMethodsToHide) do if v then tClass.__privateMethods[k] = v tClass[k] = nil end end

        return setmetatable(tClass, {
            __call = function(tC, ...)
                local tO = setmetatable({}, tC)

                tO.__private        =   {}
                tO.__type           =   tC.__type
                tO.__privateMethods =   tC.__privateMethods

                assert(xpcall(function(...) tO:init(...) end, function(tErr) return "Init Error: " .. tErr end, ...))

                return tO
            end,
            __gc = function(tO) if tO.destroy then pcall(function() tO:destroy() end) end end,
            __index = function(tSelf, tKey)
                if tKey == "__privateMethods" then return nil end
                if tSelf.__privateMethods[tKey] then return function() return tSelf.__privateMethods[tKey](tSelf) end end
                return rawget(tSelf, tKey)
            end,
        })
    end

    local function overloadOperators(tClass)
        assert(type(tClass) == "table", "[CLASS] ...")
        tClass.__add = function(tA, tB)
            assert(tA.__type == tClass.__type, "[CLASS] Attempted to add incompatible types: " .. tA.__type .. " and " .. tB.__type)
            assert(tB.__type == tClass.__type, "[CLASS] Attempted to add incompatible types: " .. tA.__type .. " and " .. tB.__type)
    
            local tResult = {}
    
            for tKey, tValue in pairs(tA.__private) do tResult[tKey] = tValue end
            for tKey, tValue in pairs(tB.__private) do tResult[tKey] = tResult[tKey] or tValue end
    
            for tKey, tValue in pairs(tA.__privateMethods) do tResult[tKey] = tValue end
            for tKey, tValue in pairs(tB.__privateMethods) do tResult[tKey] = tResult[tKey] or tValue end
    
            return setmetatable(tResult, { __type = tA.__type, __privateMethods = tResult.__privateMethods or {} })
        end
    end

    local function registerClass(tName, tPrototype, tParent)
        local tCls  =   new{__includes = {tPrototype, tParent}}

        if tParent then tCls.__super = tParent end
        tCls.__type = tName
        overloadOperators(tCls)

        return tCls
    end

    return setmetatable({
        new                 = new,
        include             = include,
        clone               = clone,
        super               = super,
        registerAccessor    = accessor,
        registerClass       = registerClass,
    }, { __call = function(_, ...) return new(...) end })
end

```