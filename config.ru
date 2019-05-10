# frozen_string_literal: true

require './require_app'
require_app

run MusicShare::App.freeze.app
