require "spec_helper"

shared_examples_for "a FileRef Datastore" do
  after(:each) do datastore.destroy_all! end

  # add_paths
  # add_files
  # remove_files
  # remove_paths
  # remove_by_sha!
  # remove_all!
  #

  describe "#create!" do
    it "adds a FileRef with the given data" do
      ref = datastore.create!({path: "/foo/bar"})
      expect(ref.path).to eql("/foo/bar")
    end

    it "raises a 'DuplicatePath' exception when a FileRef exists with the given :path" do
      datastore.create!({path: "/foo/bar"})
      expect(->{datastore.create!({path: "/foo/bar"})}).to raise_error(Duplex::Datastore::DuplicatePath)
    end

    it "raises an 'InvalidPath' exception when not given a :path" do
      expect(->{datastore.create!({path: nil})}).to raise_error(Duplex::FileRef::InvalidPath)
      expect(->{datastore.create!({})}).to raise_error(Duplex::FileRef::InvalidPath)
    end
  end

  describe "#find_by_path" do
    let(:file_ref_1) { create_file_ref(location: "/example/path") }
    let(:file_ref_2) { create_file_ref(location: "/example/path") }

    before(:each) do
      datastore.add_file_refs([file_ref_1, file_ref_2])
    end

    it "returns the FileRef with the given path" do
      found = datastore.find_by_path(file_ref_1.path)
      expect(found).to_not be_nil
      expect(found.path).to eql(file_ref_1.path)
      found = datastore.find_by_path(file_ref_2.path)
      expect(found).to_not be_nil
      expect(found.path).to eql(file_ref_2.path)
    end

    it "excludes FileRefs not exactly matching the given path" do
      expect(datastore.find_by_path("/example/path")).to be_nil
    end
  end

  describe "#find_all_by_path" do
    it "returns all FileRefs with paths containing the given path string" do
      file_ref_1 = create_file_ref(location: "/example/path")
      file_ref_2 = create_file_ref(location: "/example/path")
      datastore.add_file_refs([file_ref_1, file_ref_2])
      expect(datastore.find_all_by_path("/example/path").count).to eql(2)
    end

    it "includes FileRefs with any matching path" do
      file_ref_1 = create_file_ref(location: "/example/path")
      file_ref_2 = create_file_ref(location: "/nested/example/path")
      datastore.add_file_refs([file_ref_1, file_ref_2])
      expect(datastore.find_all_by_path("/example/path").count).to eql(2)
    end

    it "accepts regular expressions" do
      file_ref_1 = create_file_ref(location: "/example/path")
      file_ref_2 = create_file_ref(location: "/example/path")
      datastore.add_file_refs([file_ref_1, file_ref_2])
      expect(datastore.find_all_by_path(/example\/path/).count).to eql(2)
    end

    it "can use regular expressions for greater precision" do
      file_ref_1 = create_file_ref(location: "/example/path")
      file_ref_2 = create_file_ref(location: "/nested/example/path")
      datastore.add_file_refs([file_ref_1, file_ref_2])
      expect(datastore.find_all_by_path(/^\/example\/path/).count).to eql(1)
    end

    it "excludes FileRefs not matching the given path fragment" do
      file_ref_1 = create_file_ref(location: "/example/dir")
      file_ref_2 = create_file_ref(location: "/example/path")
      datastore.add_file_refs([file_ref_1, file_ref_2])
      expect(datastore.find_all_by_path("/example/path").count).to eql(1)
    end
  end

  describe "#update" do
    let(:file_ref_1) { create_file_ref(location: "/example/path") }
    let(:file_ref_2) { create_file_ref(location: "/sample/path") }

    before(:each) do
      datastore.add_file_refs([file_ref_1, file_ref_2])
    end

    it "updates the given FileRef with changed attributes" do
      attrs = {sha: "123ABC", size: 123, path: "/sample/path/file.txt", destination: "/target/path"}
      datastore.update(file_ref_1, attrs)
      updated = datastore.find_by_path(attrs[:path])
      expect(updated.sha).to eql(attrs[:sha])
      expect(updated.size).to eql(attrs[:size])
      expect(updated.path).to eql(attrs[:path])
      expect(updated.destination).to eql(attrs[:destination])
    end

    it "raises 'InvalidPath' when not given a valid :path" do
      expect(->{datastore.update(file_ref_1, {path: nil})}).to raise_error(Duplex::FileRef::InvalidPath)
    end

    it "raises 'DuplicatePath' when the FileRef's :path is used as a :path on another FileRef" do
      action = ->{datastore.update(file_ref_1, {path: file_ref_2.path})}
      expect(action).to raise_error(Duplex::Datastore::DuplicatePath)
    end

    it "raises 'DuplicatePath' when the FileRef's :destination is used as a :path on another FileRef" do
      action = ->{datastore.update(file_ref_1, {destination: file_ref_2.path})}
      expect(action).to raise_error(Duplex::Datastore::DuplicatePath)
    end

    it "raises 'DuplicatePath' when the FileRef's :path is used as a :destination on another FileRef" do
      destination = "/target/path/file.txt"
      datastore.update(file_ref_2, {destination: destination})
      action = ->{datastore.update(file_ref_1, {path: destination})}
      expect(action).to raise_error(Duplex::Datastore::DuplicatePath)
    end

    it "raises 'DuplicatePath' when the FileRef's :destination is used as a :destination on another FileRef" do
      destination = "/target/path/file.txt"
      datastore.update(file_ref_2, {destination: destination})
      action = ->{datastore.update(file_ref_1, {destination: destination})}
      expect(action).to raise_error(Duplex::Datastore::DuplicatePath)
    end

    it "raises 'NotFound' when the FileRef does not exist in the datastore" do
      file_ref = create_file_ref
      action = ->{datastore.update(file_ref, {path: "/different/path"})}
      expect(action).to raise_error(Duplex::Datastore::NotFound)
    end
  end

  describe "#destroy" do
    let(:file_ref_1) { create_file_ref }
    let(:file_ref_2) { create_file_ref }

    it "removes the given FileRefs from the Datastore" do
      datastore.add_file_refs([file_ref_1, file_ref_2])
      datastore.destroy([file_ref_1, file_ref_2])
      expect(datastore.count).to eql(0)
      expect(datastore.find_by_path(file_ref_1.path)).to be_nil
      expect(datastore.find_by_path(file_ref_2.path)).to be_nil
    end

    it "has no effect on other FileRefs in the Datastore" do
      datastore.add_file_refs([file_ref_1, file_ref_2])
      datastore.destroy([file_ref_2])
      expect(datastore.count).to eql(1)
      expect(datastore.find_by_path(file_ref_1.path)).to_not be_nil
    end

    it "has no effect when given FileRefs not present in the Datastore" do
      datastore.add_file_refs([file_ref_1, file_ref_2])
      datastore.destroy([create_file_ref, file_ref_2])
      expect(datastore.count).to eql(1)
      expect(datastore.find_by_path(file_ref_1.path)).to_not be_nil
      expect(datastore.find_by_path(file_ref_2.path)).to be_nil
    end
  end

  describe "#destroy_all!" do
    it "removes all FileRefs from the datastore" do
      file_ref_1 = create_file_ref(location: "/example/path")
      file_ref_2 = create_file_ref(location: "/sample/path")
      datastore.add_file_refs([file_ref_1, file_ref_2])
      expect(datastore.count).to eql(2)
      datastore.destroy_all!
      expect(datastore.count).to eql(0)
    end
  end

  describe "#exists?" do
    it "returns true when the given FileRef exists in the datastore" do
      file_ref_1 = create_file_ref
      file_ref_2 = create_file_ref
      datastore.add_file_refs([file_ref_1])
      expect(datastore.exists?(file_ref_1)).to eql(true)
      expect(datastore.exists?(file_ref_2)).to eql(false)
    end
  end

  describe "#unsaved_changes?" do
    it "returns true when #save! was not called after #create!" do
      datastore.create!(path: "/foo/bar")
      expect(datastore.unsaved_changes?).to eql(true)
      datastore.save!
      expect(datastore.unsaved_changes?).to eql(false)
    end

    it "returns true when #save! was not called after #update" do
      ref = datastore.create!(path: "/example/file.txt")
      datastore.save!
      datastore.update(ref, ext: "doc")
      expect(datastore.unsaved_changes?).to eql(true)
      datastore.save!
      expect(datastore.unsaved_changes?).to eql(false)
    end

    it "returns true when #save! was not called after #add_file_refs" do
      ref = create_file_ref(location: "/example/path")
      datastore.add_file_refs([ref])
      expect(datastore.unsaved_changes?).to eql(true)
      datastore.save!
      expect(datastore.unsaved_changes?).to eql(false)
    end

    it "returns true when #save! was not called after #destroy" do
      ref = create_file_ref(location: "/example/path")
      datastore.add_file_refs([ref])
      datastore.save!
      expect(datastore.unsaved_changes?).to eql(false)
      datastore.destroy([ref])
      expect(datastore.unsaved_changes?).to eql(true)
    end

    it "returns true when #save! was not called after #destroy_all!" do
      datastore.create!(path: "/example/file.txt")
      datastore.save!
      datastore.destroy_all!
      expect(datastore.unsaved_changes?).to eql(true)
      datastore.save!
      expect(datastore.unsaved_changes?).to eql(false)
    end
  end
end
