# BlockchainProject
3rd Year individual project on developing a game using blockchain technologies.


Contains smart contracts deployed on rinkeby test net for ethereum, implementing erc 721 compliant tokens.

tokens are traded and interacted with using the associated flutter app, currently web deployed at:
https://bitbeasts--server.web.app/#/

kind of like crypto kitties, with PVP and PVE activities.

# Notes

   currency: 
    0: essence
    1: rubies


species notes

0   slime      => blob
1   ooze       => blob with legs
2   amphibean  => froggo
3   crustacean => crabby
4   cat        => lion/panther/sabre tooth
5   woolly     => King Kong
6   Roc        => big bird
7   Insect     => Spider, etc
8   Reptile    => croc / salamander
9   Dragon     => dragon (oriental if pure)

attributes:
            hp
attack speed - evasion
primary damage - secondary damage
resistance - accuracy
constitution - intelligence

desc: 
hp => total health points
attack speed => attack speed value for primary and secondary attack, species dependant
evasion => ability to avoid attacks 
primary damage => damage dealt on primary hit 
secondary damage => damage dealt on secondary hit 
resistance => min damage required to deal damage
accuracy => against evasion for hit liklihood
constitution => modifier to scale damage taken
intelligence => modifier for multiple factors

strength:
damage output + damage defense
damage output = attackspeed * (primary damage + secondary damage) * accuracy
damage defense = resistance + evasion * constitution + hp


dna:
1: species
2: body
3: head
4: tail 
5: limbs 
6: wings 
7: mouth 
8: eyes 
9: primary Colour 
10: secondary Colour 
11: extra feature

fusion methods:
normal: ab + cd => ac
double slime: 0a + 0b => ab    ()
slime secondary: ab + 0d => 0a (imure slime)
slimePrimary: 0a + cd => 00   (pure slime)




costs::

retrieveex: 0.000051775
retrieveau: 0.000047934
accept challenge: 	0.000168753
make challenge: 0.000206093
levelup: 0.000063462
dungeon: 0.000167092
fusion: 0.000461797
auction: 0.000168414
extract: 0.000095724
buy extract: 0.000139112
buy auction: 0.000084671

