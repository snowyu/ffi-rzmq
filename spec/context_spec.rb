
require File.join(File.dirname(__FILE__), %w[spec_helper])

module ZMQ


  describe Context do

    context "when initializing" do
      include APIHelper

      before(:all) do
        #stub_libzmq
      end

      it "should raise an error for negative app threads" do
        lambda { Context.new -1, -1, 0 }.should raise_exception(ZMQ::ContextError)
      end

      it "should raise an error for negative io threads" do
        lambda { Context.new 1, -1, 0 }.should raise_exception(ZMQ::ContextError)
      end

      it "should not raise an error for positive thread counts" do
        lambda { Context.new 1, 1, 0 }.should_not raise_error
      end

      it "should set the :pointer accessor to non-nil" do
        ctx = Context.new 1, 1
        ctx.pointer.should_not be_nil
      end

      it "should set the :context accessor to non-nil" do
        ctx = Context.new 1, 1
        ctx.context.should_not be_nil
      end

      it "should set the :pointer and :context accessors to the same value" do
        ctx = Context.new 1, 1
        ctx.pointer.should == ctx.context
      end
      
      it "should define a finalizer on this object" do
        ObjectSpace.should_receive(:define_finalizer)
        ctx = Context.new 1, 1
      end
    end # context initializing


    context "when terminating" do
      it "should call zmq_term to terminate the library's context" do
        ctx = Context.new 1, 1
        LibZMQ.should_receive(:zmq_term).with(ctx.pointer).and_return(0)
        ctx.terminate
      end

      it "should raise an exception when it fails" do
        ctx = Context.new 1, 1
        LibZMQ.stub(:zmq_term => 1)
        lambda { ctx.terminate }.should raise_error(ZMQ::ContextError)
      end
    end # context terminate


    context "when allocating a socket" do
      it "should return a ZMQ::Socket" do
        ctx = Context.new 1, 1
        ctx.socket(ZMQ::REQ).should be_kind_of(ZMQ::Socket)
      end

      it "should raise an exception when allocation fails" do
        ctx = Context.new 1, 1
        Socket.stub(:new => nil)
        lambda { ctx.socket(ZMQ::REQ) }.should raise_error(ZMQ::SocketError)
      end
    end # context socket
  end


end # module ZMQ
