=begin
Auteur : Zouzaka
Description : Ce Scripte permet de modifier les stats d'un hero grace a une
pierre ou autre objet ...
=end
module P_Stats
  # ID de l'objet requis pour modifier les stats
  Pierre_id = 17
  Voc_no_pierre = "Tu n'a pas la pierre"
end
class Scene_Pierre < Scene_Base
  def start
    super
    create_background
    creat_window_help
    creat_window_choix_actor
    creat_window_stone
  end
  def update
    super
    @stone_window.contents.clear
    @stone_window.contents.draw_text(0,0,200,50,"#{$game_party.item_number($data_items[P_Stats::Pierre_id])} #{$data_items[P_Stats::Pierre_id].name}")
    if Input.trigger?(:B)
      if @window_actors.open?
        SceneManager.return
      else @window_choix.open?
        @window_choix.close
        @window_info.close
        @window_actors.open
        @window_actors.activate
      end
    end
  end
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)
  end
  def creat_window_choix
    @window_choix = Window_Choix.new(0,@window_help.height)
    @window_choix.set_handler(:sym,      method(:cmd_change))
  end
  def creat_window_hero_info
    @window_info = Window_Base.new(@window_choix.width,@window_help.height,Graphics.width - @window_choix.width,Graphics.height-(@window_help.height + @stone_window.height))
    @window_info.draw_actor_face(@hero_selected, 10, 10)
    @window_info.draw_actor_hp(@hero_selected, 114, 10)
    @window_info.draw_actor_mp(@hero_selected, 114, 30)
    6.times {|i| @window_info.draw_actor_param(@hero_selected, 10, 120+(i*25), i + 2) }
  end
  def window_hero_info_refresh
    @window_info.contents.clear
    @window_info.draw_actor_face(@hero_selected, 10, 10)
    @window_info.draw_actor_hp(@hero_selected, 114, 10)
    @window_info.draw_actor_mp(@hero_selected, 114, 30)
    6.times {|i| @window_info.draw_actor_param(@hero_selected, 10, 120+(i*25), i + 2) }
  end
  def creat_window_help
    @window_help = Window_Help.new(1)
    @window_help.set_text("Menu de Spécialisation")
  end
  def creat_window_choix_actor
    @window_actors = Window_Choix_Actor.new(350,50)
    @window_actors.x = Graphics.width - @window_actors.width
    @window_actors.y = @window_help.height
    @window_actors.set_handler(:hero,      method(:cmd_hero))
  end
  #Commands Select Actor ...
  def cmd_hero
    @hero_selected = $game_party.battle_members[@window_actors.index]
    creat_window_choix
    creat_window_hero_info
    @window_actors.close
  end
  #Commands Params
  def cmd_change
    if $game_party.item_number($data_items[P_Stats::Pierre_id]) >= 1
      $game_party.gain_item($data_items[P_Stats::Pierre_id], -1)
      $game_actors[@hero_selected.id].add_param(@window_choix.index, 10) if @window_choix.index <= 1
      $game_actors[@hero_selected.id].add_param(@window_choix.index, 3) if @window_choix.index >= 2
      @window_help.set_text(Vocab.param(@window_choix.index)+" Augmenté")
      @window_choix.activate
      window_hero_info_refresh
    else
      @window_help.set_text(P_Stats::Voc_no_pierre)
      @window_choix.activate
    end
  end
  def creat_window_stone
    @stone_window = Window_Base.new(Graphics.width-250,Graphics.height-60,250,60)
  end
end
class Window_Choix < Window_Command
  def window_width
    return 200
  end
  def make_command_list
    8.times{|vo| add_command("Ajouter "+Vocab.param(vo),   :sym)}
  end
end
class Window_Choix_Actor < Window_Command
  def make_command_list
    $game_party.battle_members.each{|actor| add_command(actor.name,   :hero)}
  end
end
