# ENGLISH

# Let banned players play on your server

Instead of forbidding banned players from connecting to your server, now they can join, but can't do anything on it. They are ghosts.

Translated in 3 languages : ENglish, FRench, RUssian

To Ghostban a player with ULX, the command is !ghostban / !unghostban, this will ban player without kicking him and write his ban in ULX

To Ghostban a player without ULX or when 'ulx ban' is replaced, the command is !ban / !unban

To open the config menu, the command is /ghostban

## Features :

A huge config is available with an In-Game panel, no need to change a config file. You control everything in game. To show it, type '/ghostban' in the chat

This config include :

Ghosts can...
- Spawn props : spawn props ?
- Property : Use properties ?
- Use tool : Use the toolgun ?
- Talk voice : Speak with their voice ?
- Talk chat : Speak with the chat ?
- Loadout : Have their weapons when they spawn ?
- Pickup item : Pickup items ?
- Pickup weapons : Pickup weapons ?
- Enter vehicles : Enter vehicles ?
- Suicide : Suicide ?
- Don't collide : Does they collide with (everything), with (nothing) or only with (players) ?
- Display reason : Display text at the bottom of their screen, showing reason and time left ?
- Context menu : Open the context menu ?
- Props menu : Open the props menu ?
- Game menu : Open the game menu ?
- Hurt players : Be killed by other players ?
- Does ghosts have a 'GHOST' text above their head ?
- Do Ghostban replace 'ulx ban' commande ?
- Change language to English, French or Russian


# Hooks
GhostbanGhostedPlayer(player) [client/server] : Ran after a player has been ghostbanned

GhostbanUnghostedPlayer(player) [client/server] : Ran after a player has been unghostbanned


GhostbanShouldntBan(player, time, reason) [server] : Return true to prevent ghostbanning

GhostbanShouldntUnban(player) [server] : Return true to prevent unghostbanning

GhostbanCheckPassword(steamid64, IP) [server] : Return true to prevent kick from GhostBan.percentKick


# FRENCH

# Laissez les joueurs bannis jouer sur votre serveur

Au lieu d'une simple interdiction de se connecter, les joueurs bannis pourrons venir sur votre serveur, mais ne pourrons rien faire dessus, ce sont des fantômes

Traduis en 3 langues : ENglish, FRench, RUssian

Pour Ghostban un joueur avec ULX, la commande est !ghostban / !unghostban, cela bannira le joueur sans lui faire quitter le jeu tout en inscrivant le ban dans ULX

Pour Ghostban un joueur sans ULX, la commande est !ban / !unban

Pour ouvrir le menu de configuration, la commande est /ghostban

## Fonctionnalités :

Un très grande configuration est disponible avec un panel In-Game, plus besoin d'aller modifier directement les fichiers, vous contrôlez tout dans le jeu, pour l'afficher tapez "/ghostban" dans le chat

Cette configuration inclus :

Est-ce que les fantômes peuvent...
- Spawn props : Faire spawn des props ?
- Property : Utiliser les propriétés ?
- Use tool : Utiliser le toolgun ?
- Talk voice : Parler avec le chat vocal ?
- Talk chat : Parler avec le chat textuelle ?
- Loadout : Avoir leurs armes quand ils spawn ?
- Pickup item : Prendre les items ?
- Pickup weapons : Prendre les armes ?
- Enter vehicles : Entrer dans les véhicules ?
- Suicide : Se suicider ?
- Don't collide : Traversent-ils tout (everything), rien (nothing) ou juste les joueurs (players) ? [b]Attention, si activé les fantômes ne pourrons pas être tué[/b]
- Display reason : Voyent-ils un bandeau noir en bas de leur écran indiquant la raison et le temps restant de leur ban ?
- Context menu : Ouvrir le context menu ?
- Props menu : Ouvrir le menu des props ?
- Game menu : Ouvrir le menu du jeu ?
- Hurt players : Se faire tuer par d'autres joueurs ?
- Est-ce que les autres joueurs voient 'FANTOME' au dessus de leur tête ?
- Est-ce que Ghostban remplace la commande 'ulx ban' ?
- Changement de langue en Français, Anglais ou Russe