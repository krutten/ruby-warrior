module RubyWarrior
  class Game
    
    def start
      UI.puts "Welcome to Ruby Warrior"
      
      if File.exists?(Config.path_prefix + '/.profile')
        @profile = Profile.load(Config.path_prefix + '/.profile')
      else
        make_game_directory unless File.exists?(Config.path_prefix + '/ruby-warrior')
      end
      
      profile.epic? ? play_epic_mode : play_normal_mode
    end
    
    def make_game_directory
      if UI.ask("No ruby-warrior directory found, would you like to create one?")
        Dir.mkdir(Config.path_prefix + '/ruby-warrior')
      else
        UI.puts "Unable to continue without directory."
        exit
      end
    end
    
    def play_epic_mode
      Config.delay /= 2 if Config.delay # speed up UI since we're going to be doing a lot here
      profile.current_epic_score = 0
      profile.current_epic_grades = {}
      if Config.practice_level
        @current_level = @next_level = nil
        profile.level_number = Config.practice_level
        play_current_level
      else
        playing = true
        while playing
          @current_level = @next_level = nil
          profile.level_number += 1
          playing = play_current_level
        end
        profile.save # saves the score for epic mode
      end
    end
    
    def play_normal_mode
      if Config.practice_level
        UI.puts "Unable to practice level while not in epic mode, remove -l option."
      else
        if current_level.number.zero?
          prepare_next_level
          UI.puts "First level has been generated. See the ruby-warrior directory for instructions."
        else
          play_current_level
        end
      end
    end
    
    def play_current_level
      continue = true
      current_level.load_player
      UI.puts "Starting Level #{current_level.number}"
      current_level.play
      if current_level.passed?
        if next_level.exists?
          UI.puts "Success! You have found the stairs."
        else
          UI.puts "CONGRATULATIONS! You have climbed to the top of the tower and rescued the fair maiden Ruby."
          continue = false
        end
        current_level.tally_points
        if profile.epic?
          UI.puts final_report if final_report && !continue
        else
          request_next_level
        end
      else
        continue = false
        UI.puts "Sorry, you failed level #{current_level.number}. Change your script and try again."
        if !Config.skip_input? && current_level.clue && UI.ask("Would you like to read the additional clues for this level?")
          UI.puts current_level.clue
        end
      end
      continue
    end
    
    def request_next_level
      if !Config.skip_input? && (next_level.exists? ? UI.ask("Would you like to continue on to the next level?") : UI.ask("Would you like to continue on to epic mode?"))
        if next_level.exists?
          prepare_next_level
          UI.puts "See the ruby-warrior directory for the next level README."
        else
          prepare_epic_mode
          UI.puts "Run rubywarrior again to play epic mode."
        end
      else
        UI.puts "Staying on current level. Try to earn more points next time."
      end
    end
    
    def prepare_next_level
      next_level.generate_player_files
      profile.level_number += 1
      profile.save # this saves score and new abilities too
    end
    
    def prepare_epic_mode
      profile.enable_epic_mode
      profile.level_number = 0
      profile.save # this saves score too
    end
    
    
    # profiles
    
    def profiles
      profile_paths.map { |profile| Profile.load(profile) }
    end
    
    def profile_paths
      Dir[Config.path_prefix + '/ruby-warrior/**/.profile']
    end
    
    def profile
      @profile ||= choose_profile
    end
    
    def new_profile
      profile = Profile.new
      profile.tower_path = UI.choose('tower', towers).path
      profile.warrior_name = UI.request('Enter a name for your warrior: ')
      profile
    end
    
    
    # towers
    
    def towers
      tower_paths.map { |path| Tower.new(path) }
    end
    
    def tower_paths
      Dir[File.expand_path(File.dirname(__FILE__) + '/../../towers/*')]
    end
    
    
    # levels
    
    def current_level
      @current_level ||= profile.current_level
    end
    
    def next_level
      @next_level ||= profile.next_level
    end
    
    def final_report
      if profile.calculate_average_grade
        report = ""
        report << "Your average grade for this tower is: #{Level.grade_letter(profile.calculate_average_grade)}\n\n"
        profile.current_epic_grades.each do |level, grade|
          report << "  Level #{level}: #{Level.grade_letter(grade)}\n"
        end
        report << "\nTo practice a level, use the -l option:\n\n  rubywarrior -l 3"
        report
      end
    end
    
    private
    
    def choose_profile # REFACTORME
      profile = UI.choose('profile', profiles + [[:new, 'New Profile']])
      if profile == :new
        profile = new_profile
        if profiles.any? { |p| p.player_path == profile.player_path }
          if UI.ask("Are you sure you want to replace your existing profile for this tower?")
            UI.puts "Replacing existing profile."
            profile
          else
            UI.puts "Not replacing profile."
            exit
          end
        else
          profile
        end
      else
        profile
      end
    end
    
  end
end
