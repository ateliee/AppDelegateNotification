Pod::Spec.new do |s|
  s.name         = 'AppDelegateNotification'
  s.version      = '1.0.0'
  s.summary      = 'Notification Classes.'
  s.description  = <<-DESC
                    IOS7,8 Support Notification.
                   DESC

  s.authors      = {'ateliee' => 'info@ateliee.com'}
  s.homepage     = 'http://ateliee.com'
  s.license      = { :type => 'License, Version 1.0', :text => <<-LICENSE
    Licensed under the License, Version 1.0 (the "License");
    you may not use this file except in compliance with the License.

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
  s.platform     = :ios, '7.0'
  s.source       = { :git => 'https://github.com/ateliee/AppDelegateNotification.git', :tag => '1.0.0' }
  s.source_files  = 'Classes', 'Classes/*.{h,m}'
  s.requires_arc  = true 
end
