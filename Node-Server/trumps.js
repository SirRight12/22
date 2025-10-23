// Base class for a Trump card
// A Trump card has a name, description, and an onUse function that defines its effect
// The onUse function takes the player, other player, and game as arguments
// and can modify the game state as needed.
function randRange(min, max) {
  const minCeiled = Math.ceil(min);
  const maxFloored = Math.floor(max);
  return Math.floor(Math.random() * (maxFloored - minCeiled + 1) + minCeiled);
}

// BTW "busting" is when the player's hand value exceeds the target value,
class Trump {
  constructor(name='null', description='sorry, lol',weight=0.5,onUse=()=>{}) {
    this.name = name;
    this.weight = weight; // Weight can be used to determine the likelihood of drawing this trump
    this.description = description;
    this.onUse = onUse;
  }
}
// Basically the same thing as Trump, but with an inverseUse function for undoing the trump's effect
class TrumpTable extends Trump {
    constructor(name='null', description='sorry, lol',weight=0.5,onUse=()=>{},inverseUse=()=>{}) {
        super(name, description, weight, onUse);
        this.inverseUse = inverseUse;
    }
}
//Literally the same as TrumpTable, but with a isTarget flag for trumps that modify the target value, so it's easier to search for them
class TrumpTableTarget extends TrumpTable {
    constructor(name='null', description='sorry, lol',weight=0.5,onUse=()=>{},inverseUse=()=>{}) {
        super(name, description, weight, onUse, inverseUse);
        this.isTarget = true;
    }
}

class TrumpGroup {
    constructor(trumps=[],weight=.5) {
        this.trumps = trumps
        this.weight = weight
        this.isGroup = true
    }
    selectRandom() {
        return this.trumps[randRange(0,this.trumps.length-1)]
    }
}
// Function for the 'Perfect Draw' trump
// It searches the deck for the card to get the player closest to the target
// and then draws it for them.
// If all the cards will bust the player, void the trump.
function perfectDraw(player, other, game) {
  const target = game.target;
  const deck = game.deck;

  // Find the card that gets the player closest to the target without busting
  let bestCard = null;
  let bestValue = 0;

  for (const card of deck) {
    const newValue = player.hand.reduce((sum, c) => sum + c.getValue(true), 0) + card.getValue();
    if (newValue <= target && newValue > bestValue) {
      bestValue = newValue;
      bestCard = card;
    }
  }

    // If we found a valid card, draw it for the player
    if (bestCard) return bestCard; // Return the best card found so the game can handle it
    // If all cards would bust the player, void the trump
    console.log('Perfect Draw failed: all cards would bust the player');
}
// Function for the 'Hush' trump
// It draws the top card from the deck and hides it from the other player,
function Hush(player,other,game) {
    const card = game.deck.pop(); // Draw the top card from the deck
    card.hidden = true; // Hide the card from the other player
    if (!card) {
        console.log('Hush error: no card to draw');
        return null; // If no card is available, return null
    }
    return card;
}
function Yoink(player,other,game) {
    if (other.hand.length <= 1) {
        console.log('Yoink error: other player does not have enough cards to steal');
        return null; // If the other player has no cards, return null
    }
    const stolenCard = other.hand.pop(); // Steal the top card from the other player's hand
    return stolenCard;
}
function Exchange(player,other,game) {
    if (other.hand.length === 0) {
        console.log('Exchange error: other player has no cards to exchange');
        return null; // If the other player has no cards, return null
    }
    if (player.hand.length === 0) {
        console.log('Exchange error: player has no cards to exchange');
        return null; // If the player has no cards, return null
    }
    const playerCard = player.hand.pop(); // Remove the top card from the player's hand
    const otherCard = other.hand.pop(); // Remove the top card from the other player's hand
    other.hand.push(playerCard); // Give the other player's card to the player
    player.hand.push(otherCard); // Give the other's card to the  player
    return [playerCard, otherCard]; // Return the exchanged cards for animation purposes
}
function AnteUp(player,other,game) {
    game.added_ante += 1; // Increase the ante value by 1
}
function UndoAnteUp(player,other,game) {
    game.added_ante -= 1; // Decrease the ante value by 1
}
function AnteUpPlus(player,other,game) {
    game.added_ante += 2; // Increase the ante value by 2
}
function UndoAnteUpPlus(player,other,game) {
    game.added_ante -= 2; // Decrease the ante value by 2
}
function Defend(player,other,game) {
    game.added_ante -= 1; // Decrease the ante value by 1
}
function UndoDefend(player,other,game) {
    game.added_ante += 1; // Re-Increase the ante value by 1
}
function DefendPlus(player,other,game) {
    game.added_ante -= 2; // Decrease the ante value by 2
}
function UndoDefendPlus(player,other,game) {
    game.added_ante += 2; // Re-Increase the ante value by 2
}
function removeTargetTrump(game) {
    console.log('p1Table',game.p1table,'p2Table',game.p2table)
    for (let x = 0; x < game.p1table.length; x++) {
        console.log(game.p1table[x])
        const trump = find_trump_by_name(game.p1table[x]);
        if (trump.isTarget) {
            game.p1table.splice(x, 1); // Remove existing target-modifying trump
            // In theory, there should only be one target modifier, so end the search here and return the index so the client can find it.
            return [x,1];
        }
    }
    for (let x = 0; x < game.p2table.length; x++) {
        console.log(game.p2table[x])
        const trump = find_trump_by_name(game.p2table[x]);
        if (trump.isTarget) {
            game.p2table.splice(x, 1); // Remove existing target-modifying trump
            // In theory, there should only be one target modifier, so end the search here and return the index so the client can find it.
            return [x,2];
        }
    }
    return [-1,null]; // If no target modifier is found, return -1
}
function GoForSeventeen(player,other,game) {
    game.target = 17; // Set target to 17
    return removeTargetTrump(game);
}
function UndoGoForSeventeen(player,other,game) {
    game.target = 21; // Reset target to 21
}
function GoFor24(player,other,game) {
    game.target = 24; // Set target to 24
    return removeTargetTrump(game);
}
function UndoGoFor24(player,other,game) {
    game.target = 21; // Reset target to 21
}
function Remove(player,other,game) {
    // Remove the top trump card from the other player's table
    if (other.playernum === 1) {
        if (game.p1table.length === 0) {
            console.log('Remove error: no trumps on player 1 table to remove');
            return;
        }
        const tableTrump = find_trump_by_name(game.p1table.pop());
        console.log(tableTrump)
        tableTrump.inverseUse(null, null, game);
    } else if (other.playernum === 2) {
        if (game.p2table.length === 0) {
            console.log('Remove error: no trumps on player 2 table to remove');
            return;
        }
        const tableTrump = find_trump_by_name(game.p2table.pop());
        console.log(tableTrump)
        tableTrump.inverseUse(null, null, game);
    }
}
function shuffle_deck(game) {
    for (let i = game.deck.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [game.deck[i], game.deck[j]] = [game.deck[j], game.deck[i]];
    }
}
function Refresh(player,other,game) {
    // Shuffle the player's hand back into the deck
    for (const card of player.hand) {
        card.hidden = false; // Make sure all cards are visible when shuffled back
    }
    game.deck.push(...player.hand);
    player.hand = [];
    // Shuffle the deck
    shuffle_deck()
    // Draw a new hand of 2 cards
    for (let i = 0; i < 2; i++) {
        if (game.deck.length === 0) {
            console.log('Refresh error: no cards left in deck to draw');
            break; // If no cards are left in the deck, stop drawing
        }
        const card = game.deck.pop();
        card.hidden = i == 0;
        player.hand.push(card);
    }
    return player.hand; // Return the new hand, so animations can be played
}
//Micah's dumb idea, I like it tho...
//IDEA: Shuffle player's hand back into the deck, works like refresh. Draw 4 new cards.
//          If the player goes over, apply the current ante to the player's hps as if the second player won and reduce it to 1
//          If the player remains below the target then apply half the ante to the player's hps as if the player who used the trump won
//          If the player reaches exactly the target, then apply the full ante to the player's hps as if the player who used the trump won
//      Either way, shuffle the player's 4 cards back into the deck, draw 2 new and pass
function PotOfGreed(player,other,game) {
    // If the player's hand and the deck do not make four cards, exit the execution of the function
    if (game.deck.length + player.hand.length < 4) {
        console.error("Pot of greed error, not enough cards to draw")
        return -1
    }
    game.turn = 3
    // Shuffle the player's hand back into the deck
    for (const card of player.hand) {
        card.hidden = false; // Make sure all cards are visible when shuffled back
    }
    game.deck.push(...player.hand);
    player.hand = []
    shuffle_deck(game)
    let val = 0
    const cards = []
    for (let x = 0; x < 4; x ++) {
        const card = game.deck[x]
        val += card.getValue(true)
        cards.push(card)
        player.hand.push(card)
    }
    let a = game.ante + game['added_ante']
    if (val < game.target) {
        player.hp += Math.ceil(a/2)
        other.hp -= Math.ceil(a/2)
    } else if (val == game.target) {
        player.hp += a
        other.hp -= a
    } else {
        player.hp -= a
        other.hp += a
    }
    game.deck.push(...cards)
    shuffle_deck(game)
    const newCards = []
    for (let x = 0; x < 2; x++) {
        const card = game.deck[x]
        newCards.push(card)
    }
    return [cards,newCards]

}
function DrawTwo(player,other,game) {
    return DrawSpecificNum(2,player,game);
}
function DrawThree(player,other,game) {
    return DrawSpecificNum(3,player,game);
}
function DrawFour(player,other,game) {
    return DrawSpecificNum(4,player,game);
}
function DrawFive(player,other,game) {
    return DrawSpecificNum(5,player,game);
}
function DrawSix(player,other,game) {
    return DrawSpecificNum(6,player,game);
}
function DrawSeven(player,other,game) {
    return DrawSpecificNum(7,player,game);
}
function DrawSpecificNum(num=1,player,game) {
    for (let i = 0; i < game.deck.length; i++) {
        if (game.deck[i].getValue() === num) {
            return game.deck.splice(i, 1)[0]; // Remove and return the specific card from the deck
        }
    }
    console.log(`DrawSpecificNum error: no card with value ${num} found`);
    return null; // If no such card is found, return null
}
export const trumpChances = [
  // Trumps available in the first release
  new Trump('Perfect Draw', 'Draw the perfect card from the deck', 0.6, perfectDraw),
  new Trump('Hush', 'Draw a card and hide it from the other player', 0.6, Hush),
  //Group of "draw specific card"
  new TrumpGroup([
    new Trump('Draw 2', 'Draw the 2 card from the deck, if already drawn, do nothing', 0.8, DrawTwo),
    new Trump('Draw 3', 'Draw the 3 card from the deck, if already drawn, do nothing', 0.8, DrawThree),
    new Trump('Draw 4', 'Draw the 4 card from the deck, if already drawn, do nothing', 0.8, DrawFour),
    new Trump('Draw 5', 'Draw the 5 card from the deck, if already drawn, do nothing', 0.8, DrawFive),
    new Trump('Draw 6', 'Draw the 6 card from the deck, if already drawn, do nothing', 0.8, DrawSix),
    new Trump('Draw 7', 'Draw the 7 card from the deck, if already drawn, do nothing', 0.8, DrawSeven)],
  0.8),
  new Trump('Yoink!', "Steal top card from other player's hand", 0.6, Yoink),
  // Trumps added in the second release
  
  // Group of "Small Ante-Changers"
  new TrumpGroup([
    new TrumpTable('Ante-Up', 'Increase the ante by 1 while on the table', 0.8, AnteUp, UndoAnteUp),
    new TrumpTable('Defend', 'Decrease the ante by 1 while on the table', 0.8, Defend, UndoDefend),],
  0.8),
  //Group of "Big Ante-Changers"
  new TrumpGroup([
    new TrumpTable('Ante-Up Plus', 'Increase the ante by 2 while on the table', 0.5, AnteUpPlus, UndoAnteUpPlus),
    new TrumpTable('Defend Plus', 'Decrease the ante by 2 while on the table', 0.5, DefendPlus, UndoDefendPlus),],
  0.5),
  // Group of "change target to"
  new TrumpGroup([
      new TrumpTableTarget('Go For Seventeen', 'Change the target value to 17 while on the table', 0.4, GoForSeventeen, UndoGoForSeventeen),
      new TrumpTableTarget('Go For 24','Change the target value to 24 while on the table', 0.4, GoFor24, UndoGoFor24),],
  0.7),
  new Trump('Remove', 'Remove the top trump card from the enemy\'s table', 0.6, Remove),
  new Trump('Refresh','Shuffle hand back into deck and draw new hand', 0.6,Refresh),
  // TODO: add this one lol
  //   new Trump('Exchange', "Exchange top card with other player's top card", .5, Exchange),
]
let rawTrumps = []
for (let x = 0; x < trumpChances.length; x ++) {
    let trump = trumpChances[x]
    if (trump.isGroup) {
        rawTrumps = rawTrumps.concat(trump.trumps)
    }
    rawTrumps.push(trump)
}
export const trumps = rawTrumps
function find_trump_by_name(name) {
    return trumps.find(trump => trump.name === name);
}