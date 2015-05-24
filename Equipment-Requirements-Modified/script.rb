=begin
Equipment Requirements
by Fomar0153
modified by Zouzaka
Version 1.3
----------------------
Notes
----------------------
Adds a level requirement to equipment.
----------------------
Instructions
----------------------
Notetag the weapons/armors like so:
<levelreq x>
<mhpreq x>
<mmpreq x>
<atkreq x>
<defreq x>
<matreq x>
<mdfreq x>
<agireq x>
<lukreq x>
<switchreq x>
<variablereq x,y>
<wepreq x>
<armreq x>
----------------------
Change Log
----------------------
1.0 -> 1.1 Added stat requirements
          Changed script name from Equipment Level Requirements
          to just Equipment Requirements
1.1 -> 1.2 Added switch and other equipment requirements
1.2 -> 1.3 Ajout D'une Window qui affiche les Conditions requises
           Ajout de <variablereq x,y>
           Alleger le script de base de 50 lignes
----------------------
Known bugs
----------------------
None
=end
Scenes = [Scene_Equip,Scene_Item]
  #--------------------------------------------------------------------------
  # ● If set to true then it compares the requirement with the actor's base 
  #  stat rather than their current.
  #--------------------------------------------------------------------------
EQUIPREQ_USE_BASE_STAT = false
  #--------------------------------------------------------------------------
  # ● Vocab for switch's 
  #  every switch_id in a different line
  #--------------------------------------------------------------------------

Switch_Vocab = {
# Switch_ID => "Vocab",
2 => "Visiter la Compagne",
}
  #--------------------------------------------------------------------------
  # ● Vocab for variables 
  #  every switch_id in a different line
  #--------------------------------------------------------------------------

Variable_Vocab = {
# Variable_ID => "Vocab",
2 => "Nombre de pierre a casser",
}
class Window_EquipItem
  #--------------------------------------------------------------------------
  # ● Check the requirements
  #--------------------------------------------------------------------------
  def enable?(item)
    unless item == nil
      return false if @actor.level < item.levelreq
      return false if reqstat(0) < item.mhpreq
      return false if reqstat(1) < item.mmpreq
      return false if reqstat(2) < item.atkreq
      return false if reqstat(3) < item.defreq
      return false if reqstat(4) < item.matreq
      return false if reqstat(5) < item.mdfreq
      return false if reqstat(6) < item.agireq
      return false if reqstat(7) < item.lukreq
      if item.switchreq > 0
        return false unless $game_switches[item.switchreq]
      end
      if item.variablereq != 0
        return false unless $game_variables[item.variablereq[0]] < item.variablereq[1]
      end
      if item.wepreq > 0
        e = []
        for equip in @actor.equips
          e.push(equip.id) if equip.class == RPG::Weapon
        end
        return false unless e.include?(item.wepreq)
      end
      if item.armreq > 0
        e = []
        for equip in @actor.equips
          e.push(equip.id) if equip.class == RPG::Armor
        end
        return false unless e.include?(item.armreq)
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● New Method
  #--------------------------------------------------------------------------
  def reqstat(id)
    EQUIPREQ_USE_BASE_STAT ? @actor.param_base(id) : @actor.param(id)
  end
end
module RPG
  #--------------------------------------------------------------------------
  # ● Equip Item is inherited by both Weapon and Armor
  #--------------------------------------------------------------------------
  class EquipItem
    def variablereq
      self.note =~ /<variablereq (.*),(.*)>/i ? [$1.to_i,$2.to_i] : 0
    end
    def levelreq
      self.note =~ /<levelreq (.*)>/i ? $1.to_i : 0
    end
    def mhpreq
      self.note =~ /<mhpreq (.*)>/i ? $1.to_i : 0
    end
    def mmpreq
      self.note =~ /<mmpreq (.*)>/i ? $1.to_i : 0
    end
    def atkreq
      self.note =~ /<atkreq (.*)>/i ? $1.to_i : 0
    end
    def defreq
      self.note =~ /<defreq (.*)>/i ? $1.to_i : 0
    end
    def matreq
      self.note =~ /<matreq (.*)>/i ? $1.to_i : 0
    end
    def mdfreq
      self.note =~ /<mdfreq (.*)>/i ? $1.to_i : 0
    end
    def agireq
      self.note =~ /<agireq (.*)>/i ? $1.to_i : 0
    end
    def lukreq
      self.note =~ /<lukreq (.*)>/i ? $1.to_i : 0
    end
    def switchreq
      self.note =~ /<switchreq (.*)>/i ? $1.to_i : 0
    end
    def wepreq
      self.note =~ /<wepreq (.*)>/i ? $1.to_i : 0
    end
    def armreq
      self.note =~ /<armreq (.*)>/i ? $1.to_i : 0
    end
  end
end
class Window_Requirement < Window_Base
  def initialize(x, y)
    @actor = $game_party.menu_actor
    super(x, y, Graphics.width/2, Graphics.height)
    self.openness = 0
    self.z = 250
  end
  def window_item=(window)
    @window_item = window
  end
  def open
    super
    Sound.play_ok
    refresh
  end
  def close
    super
    Sound.play_cancel
  end
  def reqstat(id)
    EQUIPREQ_USE_BASE_STAT ? @actor.param_base(id) : @actor.param(id)
  end
  def item ; return @window_item.item ; end
  def actor ; return @actor ; end
  def update
    super
    if Input.trigger?(:R)
      @actor = $game_party.menu_actor_next
      refresh
    elsif Input.trigger?(:L)
      @actor = $game_party.menu_actor_prev
      refresh
    end
  end
  def refresh
    contents.clear
    @req = ["item.levelreq","item.mhpreq","item.mmpreq","item.atkreq","item.defreq","item.matreq","item.mdfreq","item.agireq","item.lukreq"]#,"item.wepreq","item.armreq"]
    @vocab_req = [Vocab.level,Vocab.param(0),Vocab.param(1),Vocab.param(2),Vocab.param(3),Vocab.param(4),Vocab.param(5),Vocab.param(6),Vocab.param(7)]#,Vocab.weapon,Vocab.armor]
    @req_condition = ["@actor.level","reqstat(0)","reqstat(1)","reqstat(2)","reqstat(3)","reqstat(4)","reqstat(5)","reqstat(6)","reqstat(7)"]
    @t = 2
    change_color(normal_color)
    draw_text(contents.width/8, 0, contents.width, line_height, "Conditions requises")
    @req.each do |req|
      if item != nil && eval(req) != 0 && actor != nil
        eval(@req_condition[@req.index(req)]) < eval(req) ? change_color(text_color(2)) : change_color(normal_color)
        draw_text(0, line_height*@t, contents.width, line_height, @vocab_req[@req.index(req)]+" requis : "+eval(req).to_s)
        @t += 1
      end
    end
    change_color(normal_color)
    if item != nil && item.wepreq != 0 && actor != nil
      e = []
      for equip in @actor.equips 
        if equip.class == RPG::Weapon
          e.push(equip.id)
        end
      end
      change_color(text_color(2)) unless e.include?(item.wepreq)
      draw_text(0, line_height*@t, contents.width, line_height, "Arme requise : "+$data_weapons[item.wepreq].name)
      @t += 1
    end
    change_color(normal_color)
    if item != nil && item.armreq != 0 && actor != nil
      e = []
      for equip in @actor.equips
        e.push(equip.id) if equip.class == RPG::Armor
      end
      change_color(text_color(2)) unless e.include?(item.armreq)
      draw_text(0, line_height*(@t), contents.width, line_height, "Armure requise : "+$data_armors[item.armreq].name)
      @t += 1
    end
    if item && item.switchreq != 0
      $game_switches[item.switchreq] ? change_color(normal_color) : change_color(text_color(2))
      draw_text(0, line_height*(@t), contents.width, line_height, Switch_Vocab[item.switchreq])
      @t += 1
    end
    if item && item.variablereq != 0
      $game_variables[item.variablereq[0]] >= item.variablereq[1] ? change_color(normal_color) : change_color(text_color(2))
      draw_text(0, line_height*(@t), contents.width, line_height, Variable_Vocab[item.variablereq[0]]+" "+$game_variables[item.variablereq[0]].to_s+"/"+item.variablereq[1].to_s)
    end
    change_color(normal_color)
    draw_text(0, contents.height-line_height*3, contents.width, line_height, "Precedent(L)      (R)Suivant",1)
    draw_text(0, contents.height-line_height*2, contents.width, line_height, "Personnage Actuel:",1)
    draw_text(0, contents.height-line_height, contents.width, line_height,@actor.name,1)
  end
end

class Scene_MenuBase
  alias :old_update :update
  def update
    old_update    
    if Scenes.index(SceneManager.scene.class)
      if !@window_req and @item_window
        @window_req = Window_Requirement.new(Graphics.width/4,0)
        @window_req.window_item = @item_window
      end
      if Input.trigger?(:CTRL)
        if @window_req.openness == 0 && @item_window.active && @item_window.item != nil
          @background = Sprite.new
          @background.z = 200
          @background.bitmap = Bitmap.new(Graphics.width, Graphics.height)
          @background.bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0, 0, 0,128))
          @window_req.open
          @item_window.deactivate
        elsif @window_req.openness == 255
          @background.dispose if @background
          @window_req.close
          @item_window.activate
        end
      end
    end
  end
end
