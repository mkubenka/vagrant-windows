require "#{Vagrant::source_root}/plugins/providers/virtualbox/synced_folder"
require_relative '../../../../helper'

module VagrantPlugins
  module ProviderVirtualBox
    class SyncedFolder < Vagrant.plugin("2", :synced_folder)
      include VagrantWindows::Helper

      alias_method :original_prepare, :prepare

      def prepare(machine, folders, _opts)

        unless machine.is_windows?
          original_prepare
        else
          defs = []
          folders.each do |id, data|
            hostpath = Vagrant::Util::Platform.cygwin_windows_path(data[:hostpath])

            folder_name = win_friendly_share_id(id.gsub(/[\/\/]/,'_').sub(/^_/, ''))

            defs << {
              name: folder_name,
              hostpath: hostpath.to_s,
              transient: data[:transient],
            }
          end

          driver(machine).share_folders(defs)
        end
      end
    end
  end
end