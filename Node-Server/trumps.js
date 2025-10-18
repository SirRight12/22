// Base class for a Trump card
// A Trump card has a name, description, and an onUse function that defines its effect
// The onUse function takes the player, other player, and game as arguments
// and can modify the game state as needed.

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
    game.ante += 1; // Increase the ante value by 1
}
function UndoAnteUp(player,other,game) {
    game.ante -= 1; // Decrease the ante value by 1
}
function AnteUpPlus(player,other,game) {
    game.ante += 2; // Increase the ante value by 2
}
function UndoAnteUpPlus(player,other,game) {
    game.ante -= 2; // Decrease the ante value by 2
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
function Refresh(player,other,game) {
    // Shuffle the player's hand back into the deck
    game.deck.push(...player.hand);
    player.hand = [];
    // Shuffle the deck
    for (let i = game.deck.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [game.deck[i], game.deck[j]] = [game.deck[j], game.deck[i]];
    }
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
export const trumps = [
  // Trumps available in the first release
  new Trump('Perfect Draw', 'Draw the perfect card from the deck', .6, perfectDraw),
  new Trump('Hush', 'Draw a card and hide it from the other player', .6, Hush),
  new Trump('Draw 2', 'Draw the 2 card from the deck, if already drawn, do nothing', .8, DrawTwo),
  new Trump('Draw 3', 'Draw the 3 card from the deck, if already drawn, do nothing', .8, DrawThree),
  new Trump('Draw 4', 'Draw the 4 card from the deck, if already drawn, do nothing', .8, DrawFour),
  new Trump('Draw 5', 'Draw the 5 card from the deck, if already drawn, do nothing', .8, DrawFive),
  new Trump('Draw 6', 'Draw the 6 card from the deck, if already drawn, do nothing', .8, DrawSix),
  new Trump('Draw 7', 'Draw the 7 card from the deck, if already drawn, do nothing', .8, DrawSeven),
  new Trump('Yoink!', "Steal top card from other player's hand", .6, Yoink),
  // Trumps added in the second release
  new TrumpTable('Ante-Up', 'Increase the ante by 1 for this round', .8, AnteUp, UndoAnteUp),
  new TrumpTable('Ante-Up Plus', 'Increase the ante by 2 for this round', .5, AnteUpPlus, UndoAnteUpPlus),
  new Trump('Remove', 'Remove the top trump card from the enemy\'s table', .8, Remove),
  new Trump('Refresh','Shuffle hand back into deck and draw new hand',.6,Refresh),
  // TODO: add this one lol
  //   new Trump('Exchange', "Exchange top card with other player's top card", .5, Exchange),
]
function find_trump_by_name(name) {
    return trumps.find(trump => trump.name === name);
}