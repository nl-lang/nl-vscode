struct Player
  name: String
  health: Number = 100
  armored: Bool = false
end

fn Player.damage(amount: Number)
  @health = Number.max(@health - amount, 0)
  self.die if @health == 0
end

fn Player.die
  print "#{@name} died"
end

on PlayerHit as 'armor' do |target, amount|
  return amount / 2 if target.armored
end

on PlayerHit do |target: Player, amount: Number|
  target.damage amount
end

fn describe(msg)
  case msg
  when {kind: "move", to: dest}
    "moving to #{dest}"
  when Player {name} if name.len > 3
    "a player with a long name"
  when is String
    "a message: #{msg}"
  else
    "something else"
  end
end

let ayla = Player { name: "Ayla" }
Event.run "PlayerHit", ayla, 120     # Ayla died
print describe(ayla)                 # a player with a long name
