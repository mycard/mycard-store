locale = 'zh'
class Card extends Spine.Model
  @types = ['Warrior','Spellcaster','Fairy','Fiend','Zombie','Machine','Aqua','Pyro','Rock','Winged_Beast','Plant','Insect','Thunder','Dragon','Beast','Beast-Warrior','Dinosaur','Fish','Sea_Serpent','Reptile','Psychic','Divine-Beast','Creator_God']
  @_attributes = ['EARTH','WATER','FIRE','WIND','LIGHT','DARK','DIVINE']
  @card_types = ['Monster', 'Spell','Trap',null,'Normal','Effect','Fusion','Ritual',null, 'Spirit','Union','Gemini','Tuner','Synchro',null,null,'Quick-Play','Continuous','Equip','Field','Counter','Flip','Toon','Xyz']
  @configure 'Card', 'id', 'name', 'card_type', 'type','attribute','level','atk','def','description'
  @extend Spine.Model.Ajax
  @extend Spine.Events
  @url: "https://api.mongolab.com/api/1/databases/mycard/collections/cards?apiKey=508e5726e4b0c54ca4492ead"
  @locale_url: "https://api.mongolab.com/api/1/databases/mycard/collections/lang_#{locale}?apiKey=508e5726e4b0c54ca4492ead"
  @query: (q, callback)->
    $.getJSON "#{@url}&q=#{JSON.stringify(q)}", (cards) =>
      cards_id = (card._id for card in cards)
      $.getJSON "#{@locale_url}&q=#{JSON.stringify({_id: { $in: cards_id}})}", (langs) =>
        cards = (for lang in langs
          for card in cards
            if card._id == lang._id
              $.extend(lang, card)
              break

          card_type = []
          i=0
          while lang.type
            if lang.type & 1
              card_type.push @card_types[i]
            lang.type >>= 1
            i++

          {
            id: card._id,
            name: lang.name,
            card_type: card_type,
            type: (i=0; (i++ until lang.race >> i & 1); @types[i]) if lang.race
            attribute: (i = 0; (i++ until lang.attribute >> i & 1); @_attributes[i]) if lang.attribute
            level: card.level
            atk: card.atk
            def: card.def
            description: lang.desc
          }
        )
        @refresh cards
        callback(cards)

class CardUsage extends Spine.Model
  @configure "CardUsage", "card_id", "count", "side"
  @belongsTo 'card', Card

class Deck extends Spine.Controller
  events: "mouseenter .card": "show"
  key: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789*-="
  constructor: ->
    super
    CardUsage.bind("refresh change", @render)
  render: =>
    @html $("#card_template").tmpl(CardUsage.all())
  show: (e) ->
    card = $(e.target).tmplItem().data.card()
    $("#card_image").attr 'src', "http://images.my-card.in/#{card.id}.jpg"
    $("#card_name").html card.name
    $("#card_card_type").html ($.i18n.prop 'card_type.' + card_type for card_type in card.card_type).join('·')
    $("#card_type").html if card.type then $.i18n.prop 'type.'+ card.type else ""
    $("#card_attribute").html if card.attribute then $.i18n.prop 'attribute.' + card.attribute else ""
    $("#card_level").html card.level if card.level
    $("#card_atk").html card.atk || ""
    $("#card_def").html card.def || ""
    $("#card_description").html card.description
  parse: (str)->
    card_usages = (for i in [0...str.length] by 5
      decoded = 0
      for char in str.substr(i, 5)
        decoded = (decoded << 6) + @key.indexOf(char)
      card_id = decoded & 0x07FFFFFF
      side = decoded >> 29
      count = decoded >> 27 & 0x3
      {card_id: card_id, side: side, count: count}
    )
    Card.query {_id: { $in: card_usage.card_id for card_usage in card_usages}}, =>
      CardUsage.refresh card_usages

$(document).ready ->
  name = $.url().param('name')
  cards_encoded = $.url().param('cards')
  $('img#qrcode').attr('src', 'https://chart.googleapis.com/chart?chs=200x200&cht=qr&chld=|0&chl=' + encodeURIComponent("http://my-card.in/decks/?name=#{name}&cards=#{cards_encoded}"))
  $('#name').html(name)

  deck = new Deck(el: $("#deck"))
  deck.parse cards_encoded