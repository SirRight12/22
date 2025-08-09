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

export const trumps = [
  new Trump('Perfect Draw', 'Draw the perfect card from the deck', 1, perfectDraw),
  new Trump('Hush', 'Draw a card and hide it from the other player', 1, Hush),
]