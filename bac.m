% Baccarat Simulation
% Number of Baccarat Games
x = 1:20;

% Player and Banker Hands
% Ace = 1, 2-9, 10/Jack/Queen/King = 0
% -1 means card hasn't been dealt
player = [-1, -1, -1];
banker = [-1, -1, -1];

% Number of wins for Player / Banker / Tie
playerWin = 0;
bankerWin = 0;
tieWin = 0;

money = 500;
bet = 5;
choice = 1;
loseStreak = 0;


y = zeros(size(x));
pWin = zeros(size(x));
bWin = zeros(size(x));

curLosingStreak = 0;
maxLosingStreak = 0;

for i = 1:length(x)
    % Create a new shuffled deck each game
    deck = createDeck();
    deck = deck(randperm(length(deck)));
    
    % Deal Player two cards
    [initPlayer, deck] = dealCards(deck, 2);
    player(1) = rankToValue(initPlayer(1).Rank);
    player(2) = rankToValue(initPlayer(2).Rank);
    
    % Deal Banker two cards
    [initBanker, deck] = dealCards(deck, 2);
    banker(1) = rankToValue(initBanker(1).Rank);
    banker(2) = rankToValue(initBanker(2).Rank);
    
    % If either score is above 10, drop the first digit
    playerScore = mod(player(1) + player(2), 10);
    bankerScore = mod(banker(1) + banker(2), 10);
    
    % Third Card rule
    % Skip if Player or Banker has natural 8/9
    if playerScore < 8 && bankerScore < 8
        playerThirdCardDrawn = false;
        % Deal Player a third card if total is 0-5
        if playerScore <= 5
            [playerThird, deck] = dealCards(deck, 1);
            player(3) = rankToValue(playerThird(1).Rank);
            playerScore = mod(playerScore + player(3), 10);
            playerThirdCardDrawn = true;
        end
        
        bankerDraw = false;
        % Decide if banker draws a third card based on Baccarat rules
        if bankerScore <= 5 && ~playerThirdCardDrawn
            bankerDraw = true;
        elseif bankerScore <= 2
            bankerDraw = true;
        elseif bankerScore == 3 && playerThirdCardDrawn && player(3) ~= 8
            bankerDraw = true;
        elseif bankerScore == 4 && playerThirdCardDrawn && ismember(player(3), 2:7)
            bankerDraw = true;
        elseif bankerScore == 5 && playerThirdCardDrawn && ismember(player(3), 4:7)
            bankerDraw = true;
        elseif bankerScore == 6 && playerThirdCardDrawn && ismember(player(3), 6:7)
            bankerDraw = true;
        end

        if bankerDraw
            [bankerThird, deck] = dealCards(deck, 1);
            banker(3) = rankToValue(bankerThird(1).Rank);
            bankerScore = mod(bankerScore + banker(3), 10);
        end
    end
    

    [money, bet, choice] = nextMove(playerScore, bankerScore, money, bet, choice);
    if playerScore > bankerScore
        playerWin = playerWin + 1;
    elseif bankerScore > playerScore
        bankerWin = bankerWin + 1;
    else
        tieWin = tieWin + 1;
    end

    y(i) = money;
    pWin(i) = playerWin;
    bWin(i) = bankerWin;
end

subplot(1, 2, 1);
plot(x,y);
xlabel('GAMES');
ylabel('MONEY');
title('BACCARAT MONEY SIM');

subplot(1, 2, 2);
plot(x, pWin);
hold on;
plot(x, bWin);
hold off;
xlabel('GAMES');
ylabel('WINS');
title('PLAYER VS BANKER WINS');
legend('Player', 'Banker');

fprintf('PLAYER WINS: %f\n', + playerWin);
fprintf('BANKER WINS: %f\n', + bankerWin);
fprintf('TIE WINS: %f\n', + tieWin);

% Betting Strategy
% choice: Player (1), Banker (2), Tie (3)
function [newMoney, newBet, newChoice] = nextMove(playerScore, bankerScore, money, curBet, curChoice)
    if (playerScore > bankerScore && curChoice == 1) || (bankerScore > playerScore && curChoice == 2)
        newMoney = money + curBet;
        newBet = 5;
    elseif (playerScore > bankerScore && curChoice == 2) || (bankerScore > playerScore && curChoice == 1)
        newMoney = money - curBet;
        newBet = curBet * 2;
    else
        newMoney = money;
        newBet = curBet;
    end

    newChoice = curChoice;
end

% Create a deck
function deck = createDeck()
    suits = {'Hearts', 'Diamonds', 'Clubs', 'Spades'};
    ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'};
    
    % Preallocate for efficiency
    deck = repmat(struct('Suit', '', 'Rank', ''), 52, 1);
    cardIndex = 1;

    for i = 1:length(suits)
        for j = 1:length(ranks)
            deck(cardIndex).Suit = suits{i};
            deck(cardIndex).Rank = ranks{j};
            cardIndex = cardIndex + 1;
        end
    end
end

% Deal cards
function [dealtCards, remainingDeck] = dealCards(deck, numCards)
    % Ensure there are enough cards to deal
    if numCards > length(deck)
        error('Not enough cards in the deck to deal the requested number.');
    end

    % Deal the specified number of cards
    dealtCards = deck(1:numCards);

    % Remove the dealt cards from the deck
    remainingDeck = deck(numCards+1:end);
end

% Get card value based on Baccarat rules
function value = rankToValue(rank)
    if ismember(rank, {'10', 'Jack', 'Queen', 'King'})
        value = 0;
    elseif strcmp(rank, 'Ace')
        value = 1;
    else
        value = str2double(rank);
    end
end