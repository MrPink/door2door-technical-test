  # spec/Dockerfile_spec.rb

require "serverspec"
require "docker-api"
require "net/http"

describe "Dockerfile" do
  before(:all) do
    @image = Docker::Image.build_from_dir('.')

    set :os, family: :debian
    set :backend, :docker
    set :docker_image, @image.id
  end

  describe file('/etc/alpine-release') do
    it { should be_file }
  end

  it "installs the right version of Alipine" do
    expect(os_version).to include("3.3.3")
  end

  def os_version
    command("cat /etc/alpine-release").stdout
  end

  it 'should expose the http port' do
    expect(@image.json['ContainerConfig']['ExposedPorts']).to include("3000/tcp")
  end
end
