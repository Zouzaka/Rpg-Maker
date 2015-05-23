=begin
Auteur: Zouzaka
Merci a Zangther pour les amelioration et conseille qu'il ma apporté =)
Utilisation :
Créez un hero qui aura les caracteristique d'un monstre standard
Créez une classe pour chaque monstre de la BDD
Inserez dans les notes d'un monstre ca :
 
 
    <capture_dmg: 2000>
    <class_id: 11>
    <chara_name: rien>
    <chara_id: 5>
    <face_name: rien>
    <face_id: 5>
   
 
Explications :
** <capture_dmg: 2000>
  Modifiez 2000 par le nombre de dommages nessesaire a la capture
** <class_id: 11>
  Modifiez 11 par l'id de la class qui correspend au monstre
** <chara_name: rien>
  Mettez "rien" si vous voulez garder le chara de base sinon mettez le nom
  du chara du monstre
** <chara_id: 5>
  mettez l'index du chara
** <face_name: rien>
  Mettez "rien" si vous voulez garder le face de base sinon mettez le nom
  du chara du monstre
** <face_id: 5>
  mettez l'index du face
=end
module Dressage
  #indiquez l'id du hero avez les caracteristiques d'un monstre
  Actor_model_id = 1
  Window_pos = [100,100]
  Back = "Back"
  Jauge = "Jauge"
  #id du sort de capture
  ID = [80]
  Complet = "Erreur: Equipe Complete"
end
#===============================================================================
#Scene_battle modified
#===============================================================================
class Scene_Battle
  alias :dresser_update_basic :update_basic
  alias :dresser_create_all_windows :create_all_windows
  alias :dresser_on_skill_ok :on_skill_ok
  alias :dresser_on_enemy_ok :on_enemy_ok
  alias :dresser_use_item :use_item
  def create_all_windows
    dresser_create_all_windows
    creat_luck_sprits
  end
  def creat_luck_sprits
    @capture_viewport = Viewport.new(Dressage::Window_pos[0], Dressage::Window_pos[1], 150, 50)
    @capture_back = Sprite.new(@capture_viewport)
    @capture_back.bitmap = Cache.system(Dressage::Back)
    @capture_back.opacity = 0
    @capture_jauge = Sprite.new(@capture_viewport)
    @capture_jauge.bitmap = Cache.system(Dressage::Jauge)
    @capture_jauge.opacity = 0
  end
  def on_skill_ok
    @skill = @skill_window.item
    @capture_skill = is_capture_skill?
    dresser_on_skill_ok
  end
  def on_enemy_ok
    @capture_cible = @enemy_window.enemy
    @cible_id = @capture_cible.enemy_id
    @lanceur = BattleManager.actor
    dresser_on_enemy_ok
  end
  def is_capture_skill?
    Dressage::ID.each do |id|
      return true if @skill.id == id
    end
  end
  def capture_effect
    @taille = get_taille
    @capture_jauge.zoom_x = @taille.to_f/100
    if @taille < 100
      @red_tone = Tone.new(255, 0, 0)
      @capture_jauge.tone = @red_tone
    end
    26.times do |i|
      @capture_back.opacity += 10
      @capture_jauge.opacity += 10
      wait(2)
    end
    26.times do |i|
      @capture_back.opacity -= 10
      @capture_jauge.opacity -= 10
      wait(2)
    end
  end
  def get_taille
    @a = /<capture_dmg: (?<number>\d+)>/.match($data_enemies[@cible_id].note)
    if(@capture_damage*100)/(@a["number"].to_i) > 100
      return 100
    else
      return (@capture_damage.to_f*100)/(@a["number"].to_i.to_f)
    end
  end
  def use_item
    dresser_use_item
    @capture_damage = @capture_cible.result.hp_damage
    capture_monster if @capture_skill && can_capture?
    capture_effect if @capture_skill
    @capture_skill = false
  end
  def can_capture?
    @a = /<capture_dmg: (?<number>\d+)>/.match($data_enemies[@cible_id].note)
    return true if @a["number"].to_i <= @capture_damage
  end
  def capture_monster
    if $game_party.battle_members.size == 4
      @log_window.add_text(Dressage::Complet)
    else
      $game_actors.add_capture
      set_capture_param
      $game_party.add_actor($data_actors.size-1)
    end
  end
  def set_capture_param
    #set class id
    @a = /<class_id: (?<number>\d+)>/.match($data_enemies[@cible_id].note)
    $data_actors.last.class_id = @a["number"].to_i
    $game_captured.last.class_id = @a["number"].to_i
    #set chara
    @a = /<chara_name: (?<string>\w+)>/.match($data_enemies[@cible_id].note)
    unless @a["string"] == "rien"
      $data_actors.last.character_name = @a["string"].to_s
      $game_captured.last.character_name = @a["string"].to_s
      @a = /<chara_id: (?<number>\d+)>/.match($data_enemies[@cible_id].note)
      $data_actors.last.character_index = @a["number"].to_i
      $game_captured.last.character_index = @a["number"].to_i
    end
    #set face
    @a = /<face_name: (?<string>\w+)>/.match($data_enemies[@cible_id].note)
    unless @a["string"] == "rien"
      $data_actors.last.face_name = @a["string"].to_s
      $game_captured.last.face_name = @a["string"].to_s
      @a = /<face_id: (?<number>\d+)>/.match($data_enemies[@cible_id].note)
      $data_actors.last.face_index = @a["number"].to_i
      $game_captured.last.face_index = @a["number"].to_i
    end
    $data_actors.last.name = $data_enemies[@cible_id].name
    $game_captured.last.name = $data_enemies[@cible_id].name
  end
end
#===============================================================================
#Save Changer
#===============================================================================
module DataManager
  #-------------------------------------------------------------------------
  # * Aliased methods
  #-------------------------------------------------------------------------
  class << self
    alias :make_capture_save :make_save_contents
    alias :extract_capture_save :extract_save_contents
    alias :creat_capture_object :create_game_objects
    def make_save_contents
      make_capture_save.merge({:captured =>$game_captured})
    end
    #--------------------------------------------------------------------------
    # * Extract Save Contents
    #--------------------------------------------------------------------------
    def extract_save_contents(contents)
      extract_capture_save(contents)
      $game_captured        = contents[:captured]
      $data_actors.concat($game_captured)
    end
    def create_game_objects
      $game_captured          = Array.new
      creat_capture_object
    end
  end
end
#===============================================================================
#Actor Manipulation
#===============================================================================
class Game_Actors
  def add_capture
    @copy = $data_actors[Dressage::Actor_model_id]
    $game_captured << @copy
    $data_actors << @copy
  end
end
