//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import 'mocha';
import {expect} from 'chai';

interface MochaMessage {
  intField: number;
  stringField: string;
}

interface CallbackTestExtension {
  callbackWithSingleParam(completion: (param0: MochaMessage) => void): void;
  callbackWithTwoParams(completion: (param0: MochaMessage, param1: MochaMessage) => void): void;
  callbackWithSinglePrimitiveParam(completion: (param0: number) => void): void;
  callbackWithTwoPrimitiveParams(completion: (param0: number, param1: number) => void): void;
  callbackWithPrimitiveAndUddtParams(completion: (param0: number, param1: MochaMessage) => void): void;
  callbackWithPrimitiveAndArrayParams(completion: (param0: number, param1: Array<String>) => void): void;
  callbackWithPrimitiveAndDictionaryParams(completion: (param0: number, param1: Object) => void): void;
  callbackWithArrayAndUddtParams(completion: (param0: Array<String>, param1: MochaMessage) => void): void;
  callbackWithArrayAndArrayParams(completion: (param0: Array<String>, param1: Array<String>) => void): void;
  callbackWithArrayAndDictionaryParams(completion: (param0: Array<String>, param1: Object) => void): void;
  callbackWithDictionaryAndUddtParams(completion: (param0: Object, param1: MochaMessage) => void): void;
  callbackWithDictionaryAndArrayParams(completion: (param0: Object, param1: Array<String>) => void): void;
  callbackWithDictionaryAndDictionaryParams(completion: (param0: Object, param1: Object) => void): void;
}

declare var callbackTestExtension: CallbackTestExtension;

describe('Callbacks with', () => {
  it('single user defined data type is called', (done) => {
    callbackTestExtension.callbackWithSingleParam((param0: MochaMessage) => {
       expect(param0).to.deep.equal(
         {intField: 42, stringField: 'This is a string'});
       done();
    });
  });

  it('two user defined data types is called', (done) => {
    callbackTestExtension.callbackWithTwoParams((param0: MochaMessage, param1: MochaMessage) => {
       expect(param0).to.deep.equal(
         {intField: 42, stringField: 'This is a string'});
       expect(param1).to.deep.equal(
         {intField: 6, stringField: 'int param is 6'});
       done();
    });
  });

  it('single primitive type is called', (done) => {
    callbackTestExtension.callbackWithSinglePrimitiveParam((param0: number) => {
      expect(param0).to.equal(777);
      done();
    });
  });

  it('two primitive types is called', (done) => {
    callbackTestExtension.callbackWithTwoPrimitiveParams((param0: number, param1: number) => {
       expect(param0).to.equal(777);
       expect(param1).to.equal(888);
       done();
    });
  });

  it('one primitive type and one user defined data type is called', (done) => {
    callbackTestExtension.callbackWithPrimitiveAndUddtParams((param0: number, param1: MochaMessage) => {
       expect(param0).to.equal(777);
       expect(param1).to.deep.equal(
        {intField: 42, stringField: 'This is a string'});
       done();
    });
  });

  it('one primitive type and one array type is called', (done) => {
    callbackTestExtension.callbackWithPrimitiveAndArrayParams((param0: number, param1: Array<String>) => {
       expect(param0).to.equal(777);
       expect(param1).to.deep.equals(["one", "two", "three"]);
       done();
    });
  });

  it('one primitive type and one dictionary type is called', (done) => {
    callbackTestExtension.callbackWithPrimitiveAndDictionaryParams((param0: number, param1: Object) => {
       expect(param0).to.equal(777);
       expect(param1).to.deep.equal({ one: 1, two: 2, three: 3 });
       done();
    });
  });  

  it("one array type and one user defined type is called", done => {
    callbackTestExtension.callbackWithArrayAndUddtParams(
      (param0: Array<String>, param1: MochaMessage) => {
        expect(param0).to.deep.equals(["one", "two", "three"]);
        expect(param1).to.deep.equal({intField: 42, stringField: 'This is a string'});
        done();
      }
    );
  });

  it("one array type and one more array type is called", done => {
    callbackTestExtension.callbackWithArrayAndArrayParams(
      (param0: Array<String>, param1: Array<String>) => {
        expect(param0).to.deep.equals(["one", "two", "three"]);
        expect(param1).to.deep.equals(["four", "five", "six"]);
        done();
      }
    );
  });

  it("one array type and one dictionary type is called", done => {
    callbackTestExtension.callbackWithArrayAndDictionaryParams(
      (param0: Array<String>, param1: Object) => {
        expect(param0).to.deep.equals(["one", "two", "three"]);
        expect(param1).to.deep.equal({ one: 1, two: 2, three: 3 });
        done();
      }
    );
  });

  it("one dictionary type and one user defined type is called", done => {
    callbackTestExtension.callbackWithDictionaryAndUddtParams(
      (param0: Object, param1: MochaMessage) => {
        expect(param0).to.deep.equal({ one: 1, two: 2, three: 3 });
        expect(param1).to.deep.equal({intField: 42, stringField: 'This is a string'});
        done();
      }
    );
  });

  it("one dictionary type and one array type is called", done => {
    callbackTestExtension.callbackWithDictionaryAndArrayParams(
      (param0: Object, param1: Array<String>) => {
        expect(param0).to.deep.equal({ one: 1, two: 2, three: 3 });
        expect(param1).to.deep.equals(["one", "two", "three"]);
        done();
      }
    );
  });

  it("one dictionary type and one more dictionary type is called", done => {
    callbackTestExtension.callbackWithDictionaryAndDictionaryParams(
      (param0: Object, param1: Object) => {
        expect(param0).to.deep.equal({ one: 1, two: 2, three: 3 });
        expect(param1).to.deep.equal({ four: 4, five: 5, six: 6 });
        done();
      }
    );
  });
});
