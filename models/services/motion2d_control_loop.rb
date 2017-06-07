import_types_from 'base'
require 'models/services/control_loop'
CommonModels::Services::ControlLoop.declare_open_loop \
    'Motion2D', '/base/commands/Motion2D'

