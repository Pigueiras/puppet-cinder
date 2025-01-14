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
# Unit tests for cinder::backup::swift class
#

require 'spec_helper'

describe 'cinder::backup::swift' do
  let :default_params do
    {
      :backup_swift_url                   => '<SERVICE DEFAULT>',
      :backup_swift_auth_url              => '<SERVICE DEFAULT>',
      :swift_catalog_info                 => '<SERVICE DEFAULT>',
      :backup_swift_container             => 'volumebackups',
      :backup_swift_create_storage_policy => '<SERVICE DEFAULT>',
      :backup_swift_object_size           => '<SERVICE DEFAULT>',
      :backup_swift_retry_attempts        => '<SERVICE DEFAULT>',
      :backup_swift_retry_backoff         => '<SERVICE DEFAULT>',
      :backup_swift_user_domain           => '<SERVICE DEFAULT>',
      :backup_swift_project_domain        => '<SERVICE DEFAULT>',
      :backup_swift_project               => '<SERVICE DEFAULT>',
      :backup_compression_algorithm       => '<SERVICE DEFAULT>',
      :backup_swift_service_auth          => '<SERVICE DEFAULT>',
    }
  end

  let :params do
    {}
  end

  shared_examples 'cinder backup with swift' do
    let :p do
      default_params.merge(params)
    end

    it 'configures cinder.conf' do
      is_expected.to contain_cinder_config('DEFAULT/backup_driver').with_value('cinder.backup.drivers.swift.SwiftBackupDriver')
      is_expected.to contain_cinder_config('DEFAULT/backup_swift_url').with_value(p[:backup_swift_url])
      is_expected.to contain_cinder_config('DEFAULT/backup_swift_auth_url').with_value(p[:backup_swift_auth_url])
      is_expected.to contain_cinder_config('DEFAULT/swift_catalog_info').with_value(p[:swift_catalog_info])
      is_expected.to contain_cinder_config('DEFAULT/backup_swift_container').with_value(p[:backup_swift_container])
      is_expected.to contain_cinder_config('DEFAULT/backup_swift_create_storage_policy').with_value(p[:backup_swift_create_storage_policy])
      is_expected.to contain_cinder_config('DEFAULT/backup_swift_object_size').with_value(p[:backup_swift_object_size])
      is_expected.to contain_cinder_config('DEFAULT/backup_swift_retry_attempts').with_value(p[:backup_swift_retry_attempts])
      is_expected.to contain_cinder_config('DEFAULT/backup_swift_retry_backoff').with_value(p[:backup_swift_retry_backoff])
      is_expected.to contain_cinder_config('DEFAULT/backup_swift_user_domain').with_value(p[:backup_swift_user_domain])
      is_expected.to contain_cinder_config('DEFAULT/backup_swift_project_domain').with_value(p[:backup_swift_project_domain])
      is_expected.to contain_cinder_config('DEFAULT/backup_swift_project').with_value(p[:backup_swift_project])
      is_expected.to contain_cinder_config('DEFAULT/backup_compression_algorithm').with_value(p[:backup_compression_algorithm])
      is_expected.to contain_cinder_config('DEFAULT/backup_swift_service_auth').with_value(p[:backup_swift_service_auth])
    end

    context 'when overriding default parameters' do
      before :each do
        params.merge!(:backup_swift_url => 'https://controller2:8080/v1/AUTH_')
        params.merge!(:backup_swift_auth_url => 'https://controller2:5000')
        params.merge!(:swift_catalog_info => 'object-store:swift:internalURL')
        params.merge!(:backup_swift_container => 'toto')
        params.merge!(:backup_swift_create_storage_policy => 'foo')
        params.merge!(:backup_swift_object_size => '123')
        params.merge!(:backup_swift_retry_attempts => '99')
        params.merge!(:backup_swift_retry_backoff => '56')
        params.merge!(:backup_compression_algorithm => 'None')
        params.merge!(:backup_swift_service_auth => true)
      end
      it 'should replace default parameters with new values' do
        is_expected.to contain_cinder_config('DEFAULT/backup_swift_url').with_value(p[:backup_swift_url])
        is_expected.to contain_cinder_config('DEFAULT/backup_swift_auth_url').with_value(p[:backup_swift_auth_url])
        is_expected.to contain_cinder_config('DEFAULT/swift_catalog_info').with_value(p[:swift_catalog_info])
        is_expected.to contain_cinder_config('DEFAULT/backup_swift_container').with_value(p[:backup_swift_container])
        is_expected.to contain_cinder_config('DEFAULT/backup_swift_create_storage_policy').with_value(p[:backup_swift_create_storage_policy])
        is_expected.to contain_cinder_config('DEFAULT/backup_swift_object_size').with_value(p[:backup_swift_object_size])
        is_expected.to contain_cinder_config('DEFAULT/backup_swift_retry_attempts').with_value(p[:backup_swift_retry_attempts])
        is_expected.to contain_cinder_config('DEFAULT/backup_swift_retry_backoff').with_value(p[:backup_swift_retry_backoff])
        is_expected.to contain_cinder_config('DEFAULT/backup_compression_algorithm').with_value(p[:backup_compression_algorithm])
        is_expected.to contain_cinder_config('DEFAULT/backup_swift_service_auth').with_value(p[:backup_swift_service_auth])
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

      it_behaves_like 'cinder backup with swift'
    end
  end
end
