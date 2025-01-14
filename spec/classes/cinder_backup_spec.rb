#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for cinder::backup class
#

require 'spec_helper'

describe 'cinder::backup' do
  let :default_params do
    {
      :enable                => true,
      :manage_service        => true,
      :backup_manager        => '<SERVICE DEFAULT>',
      :backup_api_class      => '<SERVICE DEFAULT>',
      :backup_name_template  => '<SERVICE DEFAULT>',
      :backup_workers        => '<SERVICE DEFAULT>',
      :backup_max_operations => '<SERVICE DEFAULT>',
    }
  end

  let :params do
    {}
  end

  shared_examples 'cinder backup' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('cinder::params') }

    it 'installs cinder backup package' do
      if platform_params.has_key?(:backup_package)
        is_expected.to contain_package('cinder-backup').with(
          :name   => platform_params[:backup_package],
          :ensure => 'present',
          :tag    => ['openstack', 'cinder-package'],
        )
      end
    end

    it 'ensure cinder backup service is running' do
      is_expected.to contain_service('cinder-backup').with(
        :ensure    => 'running',
        :name      => platform_params[:backup_service],
        :enable    => true,
        :hasstatus => true,
        :tag       => 'cinder-service',
      )
    end

    it 'configures cinder.conf' do
      is_expected.to contain_cinder_config('DEFAULT/backup_manager').with_value(p[:backup_manager])
      is_expected.to contain_cinder_config('DEFAULT/backup_api_class').with_value(p[:backup_api_class])
      is_expected.to contain_cinder_config('DEFAULT/backup_name_template').with_value(p[:backup_name_template])
      is_expected.to contain_cinder_config('DEFAULT/backup_workers').with_value(p[:backup_workers])
      is_expected.to contain_cinder_config('DEFAULT/backup_max_operations').with_value(p[:backup_max_operations])
    end

    context 'when overriding parameters' do
      before :each do
        params.merge!({
          :backup_name_template  => 'foo-bar-%s',
          :backup_workers        => 1,
          :backup_max_operations => 2,
        })
      end
      it 'should replace default parameter with new value' do
        is_expected.to contain_cinder_config('DEFAULT/backup_name_template').with_value(p[:backup_name_template])
        is_expected.to contain_cinder_config('DEFAULT/backup_workers').with_value(p[:backup_workers])
        is_expected.to contain_cinder_config('DEFAULT/backup_max_operations').with_value(p[:backup_max_operations])
      end
    end

    context 'with manage_service false' do
      before :each do
        params.merge!(:manage_service => false)
      end
      it 'should not configure the service' do
        is_expected.to_not contain_service('cinder-backup')
      end
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({:os_workers => 8}))
      end

      let :platform_params do
        if facts[:osfamily] == 'Debian'
          { :backup_package => 'cinder-backup',
            :backup_service => 'cinder-backup' }
        else
          { :backup_service => 'openstack-cinder-backup' }
        end
      end

      it_behaves_like 'cinder backup'
    end
  end
end
