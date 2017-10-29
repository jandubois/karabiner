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

launcher("1", "1Password 6.app")

launcher("a", "Contacts.app") # addressbook
launcher("a", "App Store.app")

launcher("b", "/usr/local/bin/open-chrome-app {{BLUEJEANS_URL}}")

launcher("c", "Google Chrome.app")
launcher("c", "Calendar.app")

launcher("d", "DEVONthink Pro.app")
launcher("d", "Script Debugger.app")

launcher("e", "/Applications/Emacs.app")

launcher("f", "OmniFocus.app")
launcher("f", "Finder.app")

launcher("g", "/usr/local/bin/open-chrome-app https://mail.google.com")

launcher("i", "iThoughtsX.app")
launcher("i", "iTunes.app")

launcher("l", "OmniOutliner.app")

launcher("m", "Mail.app")
launcher("m", "Messages.app")

launcher("n", "Notes.app")

launcher("p", "System Preferences.app")
launcher("p", "Photos.app")

launcher("q", "Quiver.app")

launcher("r", "/usr/local/bin/open-chrome-app {{ROCKETCHAT_URL}}")
launcher("r", "/usr/local/bin/open-chrome-app https://feedly.com") # rss

launcher("s", "iTerm.app") # shell
launcher("s", "Safari.app")

launcher("t", "/usr/local/bin/open-chrome-app https://trello.com")

launcher("v", "VMware Fusion.app")
launcher("v", "VirtualBox.app")

launcher("y", "Yep.app")

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