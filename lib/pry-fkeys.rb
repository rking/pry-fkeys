require 'pry'

module PryFkeys
  class << self
    def inputrc_path; File.expand_path '~/.inputrc' end

    def on_clunky_readline?
      Readline::VERSION[/edit/i]
    end

    def inputrc_customized_for_ruby?
      File.exists? inputrc_path and File.read(inputrc_path)[/\$if\s*Ruby/]
    end

    def install_comma_debugging_aliases
      psuedo_alias ',s', 'step'
      psuedo_alias ',n', 'next'
      psuedo_alias ',c', 'continue'
      psuedo_alias ',f', 'finish'

      psuedo_alias ',w', 'whereami'

      # ,, aliases all the ",cmd"s to "cmd". Undo with a second ",,"
      command ',,',
        'toggle ,-prefixes off/on commands, for terse input' do
        abbreviations = []
        commands.keys.reject do |cmd|
          cmd.class != String or cmd[0] != ',' or cmd == ',,'
        end.each do |e|
          terse = e[1..-1]
          # TODO: check to see if you're stomping on something, first.
          Pry.commands.alias_command terse, e
          abbreviations << terse
        end
        Pry.commands.command ',,', 'unsplat all ,-commands' do
          abbreviations.each do |too_terse|
            Pry.commands.delete too_terse
          end
        end
        Pry.output.puts "Added commands: #{abbreviations.join ' '}"
      end
    end

    def explain
      Pry.output.puts <<-EOT
\e[32mThese are the current bindings:\e[0m

#{THE_WHOLE_POINT}

If you:
- Paste that into ~/.inputrc (or run inputrc! from Pry)
- Restart pry
Then it should be fully functional; if it isn't, please file an issue:
    https://github.com/rking/pry-fkeys/issues

Or, if you just want to suppress the warning, you can put '$if Ruby' anywhere in
~/.inputrc and it'll stop bothering you.
      EOT
      'Almost there...'
    end

    def append!
      warning = "\e[31mFound '$if Ruby' block, but running anyway...\e[0m\n" \
        if inputrc_customized_for_ruby?
      Pry.output.puts "#{warning}Saving F-keys bindings to #{inputrc_path}"
      File.open inputrc_path, 'a' do |f|
        f.write THE_WHOLE_POINT
      end
      'Done - Restart pry to see the effects'
    end
  end

  if on_clunky_readline?
    warn <<-EOT
\e[31mPry-de found EditLine's Readline wrapper.\e[0m
For the full keyboard experience, install GNU Readline:

# For RVM:
#
    brew install readline
    brew link readline
    echo ruby_configure_flags=--with-readline-dir=/usr/local/opt/readline >> \
      ~/.rvm/user/db
    rvm reinstall #{RUBY_VERSION}

# For rbenv:
    brew install readline ruby-build
    export CONFIGURE_OPTS=--with-readline-dir=`brew --prefix readline`
    rbenv install #{RUBY_VERSION} # or #{RUBY_VERSION}-pNNN
    EOT
    install_comma_debugging_aliases
  end

  unless inputrc_customized_for_ruby?
    warn <<-EOT
Pry-de found no Ruby customization in ~/.inputrc. Run 'inputrc?' to learn more.
    EOT
  end

  THE_WHOLE_POINT = <<-EOT
$if Ruby
    $if mode=vi
        set keymap vi-command
        "[14~":   "Ils -l\\n"        # <F4>
        "[15~":   "\\C-lIwhereami\\n" # <F5>
        "[28~":   "Iedit -c\\n"      # <Shift+F5>
        "[17~":   "Iup\\n"           # <F6>
        "[18~":   "Idown\\n"         # <F7>
        "[19~":   "Icontinue\\n"     # <F8>
        "[32~":   "Itry-again\\n"    # <Shift-F8>
        "[21~":   "Inext\\n"         # <F10>
        "[23~":   "Istep\\n"         # <F11>
        "[23$":   "Ifinish\\n"       # Shift+<F11>
        # Cross-terminal compatibility:
        "[19;2~": "Itry-again\\n"    # <Shift-F8> (xterm/gnome-terminal)
        "[23;2~": "Ifinish\\n"       # Shift+<F11> (xterm/gnome-terminal)
        "OS": "Ils -l\\n"            # <F4>
        "OA": previous-history
        "[A": previous-history
        "OB": next-history
        "[B": next-history
    $else
        # Emacs Bindings:
        "\\e[14~":   "ls -l\\n"
        "\\e[OS":    "ls -l\\n"
        "\\e[15~":   "\\C-lwhereami\\n"
        "\\e[28~":   "edit -c\\n"
        "\\e[17~":   "up\\n"
        "\\e[18~":   "down\\n"
        "\\e[19~":   "continue\\n"
        "\\e[32~":   "try-again\\n"
        "\\e[19;2~": "try-again\\n"
        "\\e[21~":   "next\\n"
        "\\e[23~":   "step\\n"
        "\\e[23$":   "finish\\n"
        "\\e[23;2~": "finish\\n"
    $endif
$endif
  EOT
end

def inputrc?
  PryFkeys.explain
end

def inputrc!
  PryFkeys.append!
end
