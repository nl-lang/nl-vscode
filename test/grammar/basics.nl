# SYNTAX TEST "source.nl" "NL basics"

## a doc comment
# <- comment.line.double-number-sign.documentation.nl punctuation.definition.comment.nl
#^^^^^^^^^^^^^^^ comment.line.double-number-sign.documentation.nl

### three hashes are a plain comment
# <- comment.line.number-sign.nl

import { foo, bar } from 'filename'
# <- meta.import.nl keyword.control.import.nl
#        ^^^ variable.other.import.nl
#                   ^^^^ keyword.control.import.nl
#                         ^^^^^^^^ string.quoted.single.nl

pub async fn load(id: Number, *rest: any): Task?
# <- storage.modifier.pub.nl
#   ^^^^^ storage.modifier.async.nl
#         ^^ storage.type.function.nl
#            ^^^^ entity.name.function.nl
#                 ^^ variable.parameter.nl
#                   ^ punctuation.separator.annotation.nl
#                     ^^^^^^ support.type.primitive.nl
#                             ^ keyword.operator.rest.nl
#                              ^^^^ variable.parameter.nl
#                                    ^^^ support.type.primitive.nl
#                                          ^^^^ entity.name.type.nl
#                                              ^ keyword.operator.optional.nl
end
# <- keyword.control.nl

fn Player.damage(amount: Number)
#  ^^^^^^ entity.name.type.nl
#         ^^^^^^ entity.name.function.nl
  @health = Number.max(@health - amount, 0)
# ^^^^^^^ variable.other.instance.nl
# ^ punctuation.definition.variable.nl
#           ^^^^^^ support.class.builtin.nl
#                  ^^^ entity.name.function.member.nl
  self.die if @health == 0
# ^^^^ variable.language.self.nl
#      ^^^ variable.other.member.nl
#          ^^ keyword.control.nl
#                     ^^ keyword.operator.comparison.nl
end

fn Foo.+(right)
#      ^ entity.name.function.nl
end

fn Foo.[]=(key, value)
#      ^^^ entity.name.function.nl
#          ^^^ variable.parameter.nl
end

let c = fn(a: Number): nil print('hello world') end
#       ^^ storage.type.function.nl
#          ^ variable.parameter.nl
#                      ^^^ support.type.primitive.nl
#                          ^^^^^ entity.name.function.call.nl
#                                ^^^^^^^^^^^^^ string.quoted.single.nl
#                                               ^^^ keyword.control.nl

let b = "a #{x.y} b"
#       ^ string.quoted.double.nl punctuation.definition.string.begin.nl
#          ^^ punctuation.section.embedded.begin.nl
#            ^ meta.embedded.line.nl variable.other.nl
#              ^ variable.other.member.nl
#               ^ punctuation.section.embedded.end.nl
#                ^^ string.quoted.double.nl
#                  ^ punctuation.definition.string.end.nl

let e = "tab\t quote\" hash\# bad\q"
#           ^^ constant.character.escape.nl
#                   ^^ constant.character.escape.nl
#                          ^^ constant.character.escape.nl
#                                ^^ invalid.illegal.escape.nl

let r = 'raw \n \' done'
#            ^^ string.quoted.single.nl
#               ^^ constant.character.escape.nl

let h = """-
#       ^^^ string.quoted.triple.nl punctuation.definition.string.begin.nl
#          ^ storage.modifier.heredoc.nl
  text #{a}
# ^^^^ string.quoted.triple.nl
#      ^^ punctuation.section.embedded.begin.nl
"""
# <- string.quoted.triple.nl punctuation.definition.string.end.nl

let raw = """=
#         ^^^ string.quoted.triple.raw.nl punctuation.definition.string.begin.nl
#            ^ storage.modifier.heredoc.nl
  no #{interpolation}
# ^^^^^^^^^^^^^^^^^^^ string.quoted.triple.raw.nl
#    ^^ -punctuation.section.embedded.begin.nl
"""

let n = 0xff + 1_000 * 5e+20
#       ^^^^ constant.numeric.hex.nl
#              ^^^^^ constant.numeric.decimal.nl
#                      ^^^^^ constant.numeric.decimal.nl

print :string.len("x"), :type(a), conn:sendMessage("hi")
# <- support.function.builtin.nl
#     ^ punctuation.definition.lua-path.nl
#      ^^^^^^ variable.other.lua.nl
#                        ^^^^ support.function.lua.nl
#                                     ^ punctuation.accessor.method.nl
#                                      ^^^^^^^^^^^ entity.name.function.method.lua.nl

let city = user?.address?.city.upcase ?? "unknown"
#              ^^ keyword.operator.nil-safe.nl
#                ^^^^^^^ variable.other.member.nl
#                                     ^^ keyword.operator.nil-safe.nl

on PlayerHit as 'armor' do |target: Player, amount|: nil
# <- storage.type.event.nl
#  ^^^^^^^^^ entity.name.function.event.nl
#            ^^ keyword.operator.type.nl
#                       ^^ keyword.control.do.nl
#                          ^ punctuation.definition.parameters.begin.nl
#                           ^^^^^^ variable.parameter.nl
#                                   ^^^^^^ entity.name.type.nl
#                                           ^^^^^^ variable.parameter.nl
#                                                 ^ punctuation.definition.parameters.end.nl
#                                                    ^^^ support.type.primitive.nl
  return amount / 2 if target.armored
end

let add = |a, b| -> a + b
#         ^ punctuation.definition.parameters.begin.nl
#          ^ variable.parameter.nl
#             ^ variable.parameter.nl
#                ^^ keyword.operator.arrow.nl
let double = x -> x * 2
#            ^ variable.parameter.nl
let ready = || -> true
#           ^^ punctuation.definition.parameters.nl
let either = a || b
#              ^^ keyword.operator.logical.nl

for i in 1..10 step 2
# <- keyword.control.for.nl
#     ^^ keyword.control.in.nl
#         ^^ keyword.operator.range.nl
#              ^^^^ keyword.control.step.nl
end

case msg
# <- keyword.control.nl
when {kind: "move", to: dest}
# <- keyword.control.nl
#     ^^^^ support.type.property-name.nl
#         ^ punctuation.separator.key-value.nl
#                   ^^ support.type.property-name.nl
#                       ^^^^ variable.other.nl
when Player {name} if name.len > 3
#    ^^^^^^ entity.name.type.nl
#            ^^^^ variable.other.nl
when is String
#    ^^ keyword.operator.type.nl
#       ^^^^^^ support.type.primitive.nl
else
end

let a = Foo { name: "Ayla", hp: 1 } |> describe
#       ^^^ entity.name.type.nl
#             ^^^^ support.type.property-name.nl
#                                   ^^ keyword.operator.pipe.nl

struct Bar : Foo
# <- storage.type.struct.nl
#      ^^^ entity.name.type.struct.nl
#          ^ punctuation.separator.inheritance.nl
#            ^^^ entity.other.inherited-class.nl
  c: Table = {}
# ^ variable.other.nl
#    ^^^^^ support.type.primitive.nl
#          ^ keyword.operator.assignment.nl
end

interface From<T> for Foo
# <- storage.type.interface.nl
#         ^^^^ entity.name.type.interface.nl
#              ^ entity.name.type.parameter.nl
#                 ^^^ keyword.control.for.nl
#                     ^^^ entity.name.type.nl
end

type Point = {x: Number, y: Number} | ~String
# <- storage.type.type.nl
#    ^^^^^ entity.name.type.alias.nl
#             ^ support.type.property-name.nl
#                ^^^^^^ support.type.primitive.nl
#                                   ^ keyword.operator.union.nl
#                                     ^ keyword.operator.negation.nl

module Foo.Bar
# <- storage.type.module.nl
#      ^^^ entity.name.type.module.nl
#          ^^^ entity.name.type.module.nl
end

let v = Direction.North
#       ^^^^^^^^^ entity.name.type.nl
#                 ^^^^^ entity.name.type.nl
const MAX_HP = 100
#     ^^^^^^ constant.other.caps.nl

a! + x.type + @type
# <- variable.other.nl
#^ keyword.operator.nocall.nl
#      ^^^^ variable.other.member.nl
#             ^^^^^ variable.other.instance.nl
raise "oops" unless done
# <- support.function.builtin.nl
#            ^^^^^^ keyword.control.nl
let t = spawn work(1).await
#       ^^^^^ keyword.control.nl
#                     ^^^^^ keyword.control.await.nl
