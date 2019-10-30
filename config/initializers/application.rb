# frozen_string_literal: true

# Load all patches
require 'patch/all'

# Force new ConnectionPool after patching
::ActiveRecord::Base.establish_connection

# Patch draper for collection streaming support
require 'server/streaming/collection'

::Draper::CollectionDecorator.include ::Server::Streaming::Collection


# Setup custom database types
require 'server/types/duration'
require 'server/types/uuid4'

ActiveRecord::Type.register :uuid, ::Server::Types::UUID4, override: true
ActiveRecord::Type.register :interval, ::Server::Types::Duration


# Ensure timestamps use a high precision in JSON
::ActiveSupport::JSON::Encoding.time_precision = 9
