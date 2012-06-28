require "mothership/base"
require "mothership/command"
require "mothership/parser"
require "mothership/help"

class Mothership
  # global options
  @@global = Command.new(self, "(global options)")

  class << self
    # define a global option
    def option(name, options = {}, &default)
      @@global.add_input(name, options, &default)
    end

    # parse argv, by taking the first arg as the command, and the rest as
    # arguments and flags
    #
    # arguments and flags can be in any order; all flags will be parsed out
    # first, and the bits left over will be treated as arguments
    def start(argv)
      return new.invoke(:help) if argv.empty?

      @@inputs = Inputs.new(@@global, self, {})

      name, *argv =
        Parser.new(@@global).parse_flags(
          @@inputs.inputs,
          argv)

      cname = name.gsub("-", "_").to_sym

      cmd = @@commands[cname]

      raise "unknown command '#{name}'" unless cmd

      cmd.invoke(Parser.new(cmd).inputs(argv))
    end
  end

  # get value of global option
  def option(name, *args)
    @@inputs[name, *args]
  end

  # test if an option was explicitly provided
  def option_given?(name)
    @@inputs.given? name
  end
end
