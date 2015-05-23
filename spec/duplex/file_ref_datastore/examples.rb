require "spec_helper"

shared_examples_for "a FileRef Datastore" do
  after(:each) do datastore.destroy_all! end

  describe "#create!" do
    it "adds a FileRef with the given data" do
      ref = datastore.create!({path: "/foo/bar"})
      expect(ref.path).to eql("/foo/bar")
    end

    it "raises a 'DuplicatePath' exception when a FileRef exists with the given :path" do
      datastore.create!({path: "/foo/bar"})
      expect(->{datastore.create!({path: "/foo/bar"})}).to raise_error(Duplex::FileRefDatastore::DuplicatePath)
    end

    it "raises an 'InvalidPath' exception when not given a :path" do
      expect(->{datastore.create!({path: nil})}).to raise_error(Duplex::FileRef::InvalidPath)
      expect(->{datastore.create!({})}).to raise_error(Duplex::FileRef::InvalidPath)
    end
  end

  describe "#find_in_path" do
    it "returns all FileRefs located within the given path" do
      datastore.create!({path: "/foo/bar"})
      datastore.create!({path: "/foo/lux"})
      expect(datastore.find_in_path("/foo").count).to eql(2)
    end

    it "excludes FileRefs not located within the given path" do
      datastore.create!({path: "/foo/bar"})
      datastore.create!({path: "/bar/foo"})
      expect(datastore.find_in_path("/foo").count).to eql(1)
    end
  end

  describe "#find_by_path_fragment" do
    it "returns all FileRefs located matching the given path fragment" do
      datastore.create!({path: "/foo/bar"})
      datastore.create!({path: "/foo/lux"})
      expect(datastore.find_by_path_fragment("/foo").count).to eql(2)
    end

    it "includes FileRefs located within any matching path" do
      datastore.create!({path: "/foo/bar/lux"})
      datastore.create!({path: "/bar/foo/bar"})
      expect(datastore.find_by_path_fragment("/foo/bar").count).to eql(2)
    end

    it "excludes FileRefs not matching the given path fragment" do
      datastore.create!({path: "/foo/bar/lux"})
      datastore.create!({path: "/bar/foo"})
      expect(datastore.find_by_path_fragment("/bar/lux").count).to eql(1)
    end
  end

  describe "#update_path!" do
    it "updates the given FileRef with the given path" do
      ref = datastore.create!({path: "/foo/bar"})
      datastore.update_path!(ref, "/foo/lux")
      updated = datastore.find_in_path("/foo/lux")
      expect(updated.count).to eql(1)
      expect(updated.first.path).to eql("/foo/lux")
    end

    it "returns the updated FileRef" do
      ref = datastore.create!({path: "/foo/bar"})
      updated = datastore.update_path!(ref, "/foo/lux")
      expect(updated.path).to eql("/foo/lux")
    end

    it "raises a 'DuplicatePath' exception when a FileRef exists with the given :path" do
      datastore.create!({path: "/foo/bar"})
      ref = datastore.create!({path: "/foo/lux"})
      expect(->{datastore.update_path!(ref, "/foo/bar")}).to raise_error(Duplex::FileRefDatastore::DuplicatePath)
    end

    it "raises an 'InvalidPath' exception when not given a :path" do
      ref = datastore.create!({path: "/foo/lux"})
      expect(->{datastore.update_path!(ref, nil)}).to raise_error(Duplex::FileRef::InvalidPath)
    end

    it "raises a 'NotFound' exception when FileRef does not exist in the datastore" do
      ref = Duplex::FileRef.new({path: "/foo/bar"})
      expect(->{datastore.update_path!(ref, "/foo/lux")}).to raise_error(Duplex::FileRefDatastore::NotFound)
    end
  end

  describe "#destroy_all!" do
    it "removes all FileRefs from the datastore" do
      datastore.create!({path: "/foo/bar"})
      datastore.create!({path: "/foo/lux"})
      datastore.destroy_all!
      expect(datastore.count).to eql(0)
    end
  end
end
