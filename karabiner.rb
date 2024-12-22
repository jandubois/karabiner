#!/usr/bin/env ruby
# coding: utf-8

require 'erb'
include ERB::Util

require 'json'

@launch_commands = {}
@launchers = []

def launchers
  JSON.generate(@launchers)
end

def launcher(key_code, shell_command)
  modifiers = { mandatory: [ "right_option" ] }
  unless @launch_commands[key_code].nil?
    modifiers[:mandatory] << "right_command"
  end
  @launch_commands[key_code] ||= []
  @launch_commands[key_code] << shell_command

  if shell_command.end_with? ".app"
    shell_command = "open -a '#{shell_command}'"
  end

  from = { key_code: key_code, modifiers: modifiers }
  to = [ { shell_command:  shell_command } ]
  @launchers << { from: from, to: to, type: "basic" }
end

if `sw_vers -productVersion`.split('.')[0].to_i < 13
  preferences = "Preferences"
else
  # "System Preferences" become "System Settings" in macOS Ventura
  preferences = "Settings"
end

open_web_app = "$HOME/Dropbox/bin/open-web-app"

launcher("1", "1Password.app")
launcher("1", "ChatGPT.app")

launcher("a", "Agenda.app")
launcher("a", "App Store.app")

launcher("b", "Safari.app") # browser

launcher("c", "Google Chrome.app")
launcher("c", "Contacts.app")

launcher("d", "DEVONthink 3.app")
launcher("d", "Dash.app")

launcher("e", "/Applications/Emacs.app")
launcher("e", "Microsoft Edge.app")

launcher("f", "Finder.app")
launcher("f", "#{open_web_app} https://feedly.com")

launcher("g", "GoLand.app")
launcher("g", "#{open_web_app} https://mail.google.com")

launcher("h", "HoudahSpot.app")
launcher("h", "Hazel.app")

launcher("i", "iThoughtsX.app")

launcher("j", "#{open_web_app} {{JENKINS_URL}}")
launcher("j", "#{open_web_app} {{JIRA_URL}}")

launcher("k", "Keyboard Maestro.app")

launcher("l", "OmniOutliner.app")

launcher("m", "Mail.app")
launcher("m", "Messages.app")

launcher("n", "Notes.app")

launcher("o", "OmniFocus.app")
launcher("o", "Day One.app")

launcher("p", "System #{preferences}.app")
launcher("p", "Photos.app")

launcher("q", "Quiver.app")

launcher("r", "OmniGraffle.app")
launcher("r", "/Applications/Rancher Desktop.app")

launcher("s", "Script Debugger.app")
launcher("s", "Slack.app")

launcher("t", "iTerm.app") # terminal

launcher("u", "Music.app")

launcher("v", "Visual Studio Code.app")
launcher("v", "VMware Fusion.app")

launcher("w", "Windows App.app")
launcher("w", "MacWhisper.app")

launcher("x", "#{open_web_app} https://www.netflix.com/browse")
launcher("x", "#{open_web_app} https://app.plex.tv/desktop")

launcher("y", "Yep.app")
launcher("y", "#{open_web_app} https://www.youtube.com")

launcher("z", "open vnc://zombo")
launcher("z", "open vnc://zark")

def mapping(from, to)
  { from: { key_code: from }, to: { key_code: to } }
end

def microsoft_keyboard(product_id)
  device = {
    disable_built_in_keyboard_if_exists: false,
    fn_function_keys: [],
    identifiers: {
      is_keyboard: true,
      is_pointing_device: false,
      product_id: product_id,
      vendor_id: 1118
    },
    ignore: false,
    simple_modifications: [
      mapping("application", "right_option"),
      mapping("left_command", "left_option"),
      mapping("left_option", "left_command"),
      mapping("right_option", "right_command"),
    ]
  }
  JSON.generate(device)
end


template = ERB.new(DATA.read)
#puts template.result
puts JSON.pretty_generate(JSON.parse(template.result), :indent => "    ")

__END__
{
    "global": {
        "check_for_updates_on_startup": true,
        "show_in_menu_bar": true,
        "show_profile_name_in_menu_bar": false
    },
    "profiles": [
        {
            "complex_modifications": {
                "parameters": {
                    "basic.to_if_alone_timeout_milliseconds": 1000
                },
                "rules": [
                    {
                        "description": "Application launcher.",
                        "manipulators": <%= launchers() %>
                    },
                    <%= ERB.new(File.read("hyper.json.erb")).result %>,
                    <%= ERB.new(File.read("omnifocus.json.erb")).result %>,
                    <%= ERB.new(File.read("terminal.json.erb")).result %>
                ]
            },
            "devices": [
               <%= microsoft_keyboard(1957) %>,
               <%= microsoft_keyboard(219) %>
            ],
            "fn_function_keys": [ <%= ERB.new(File.read("fn.json.erb")).result %> ],
            "name": "Default profile",
            "selected": true,
            "simple_modifications": [],
            "virtual_hid_keyboard": {
                "caps_lock_delay_milliseconds": 0,
                "keyboard_type": "ansi"
            }
        }
    ]
}
