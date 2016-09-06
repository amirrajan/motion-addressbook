describe AddressBook do
  ios_version = UIDevice.currentDevice.systemVersion.to_i

  subject { AddressBook }


  it { is_expected.to respond_to(:instance) }


  it { is_expected.to respond_to(:authorized?) }
  context "delegates to auth_handler" do
    subject { subject.authorized? }
    let(:mock_auth_handler) { mock(:granted?, return: true) }

    before { subject.mock(:auth_handler, return: mock_auth_handler) }

    it { is_expected.to be_truthy }
  end


  it { is_expected.to respond_to(:authorization_status) }
  context "delegates to auth_handler" do
    subject { subject.authorization_status }
    let(:mock_auth_handler) { mock(:status, return: mock_response) }
    let(:mock_response) { :mock_response }

    before { subject.mock(:auth_handler, return: mock_auth_handler) }

    it { is_expected.to eq(mock_response) }
  end


  it { is_expected.to respond_to(:can_attempt_access?) }
  [
    :authorized,
    :not_determined
  ].each do |status|
    context "authorization_status is #{status}" do
      subject { subject }
      before { subject.mock(:authorization_status, return: status) }

      it { expect(subject.can_attempt_access?).to be_truthy }
    end
  end
  context "authorization_status is denied" do
    subject { subject }
    before { subject.mock(:authorization_status, return: :denied) }

    it { expect(subject.can_attempt_access?).to be_falsey }
  end


  it { is_expected.to respond_to(:framework_as_sym) }
  if [6, 7, 8].include?(ios_version)
    it { expect(subject.framework_as_sym).to eq(:ab) }
  elsif [9, 10].include?(ios_version)
    it { expect(subject.framework_as_sym).to eq(:cn) }
  else
    it { expect(subject.framework_as_sym).to raise_error }
  end


  it { is_expected.to respond_to(:respond_to?) }
  context "delegates its unknown methods to the instance" do
    subject { subject }
    let(:method_name) { :mock_method }
    let(:mock_response) { "passed" }
    let(:mock_instance) { mock(method_name, return: mock_response) }

    before { subject.mock(:instance, return: mock_instance) }

    it { subject.respond_to?(method_name).to be_truthy }
    it { subject.send(method_name).to eq(mock_response) }
  end


  it { is_expected.to eq(Contacts) }
end
