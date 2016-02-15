//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import StdlibUnittest

extension TestSuite {
  /// Adds a set of tests for `RangeReplaceableCollection` that is also a
  /// slice type.
  public func addForwardRangeReplaceableSliceTests<
    C : RangeReplaceableCollection,
    CollectionWithEquatableElement : RangeReplaceableCollection
    where
    C.SubSequence == C,
    CollectionWithEquatableElement.Iterator.Element : Equatable
  >(
    testNamePrefix: String = "",
    makeCollection: ([C.Iterator.Element]) -> C,
    wrapValue: (OpaqueValue<Int>) -> C.Iterator.Element,
    extractValue: (C.Iterator.Element) -> OpaqueValue<Int>,

    makeCollectionOfEquatable: ([CollectionWithEquatableElement.Iterator.Element]) -> CollectionWithEquatableElement,
    wrapValueIntoEquatable: (MinimalEquatableValue) -> CollectionWithEquatableElement.Iterator.Element,
    extractValueFromEquatable: ((CollectionWithEquatableElement.Iterator.Element) -> MinimalEquatableValue),

    checksAdded: Box<Set<String>> = Box([]),
    resiliencyChecks: CollectionMisuseResiliencyChecks = .all,
    outOfBoundsIndexOffset: Int = 1
  ) {
    var testNamePrefix = testNamePrefix

    // Don't run the same tests twice.
    if checksAdded.value.contains(#function) {
      return
    }
    checksAdded.value.insert(#function)

    addForwardRangeReplaceableCollectionTests(
      testNamePrefix,
      makeCollection: makeCollection,
      wrapValue: wrapValue,
      extractValue: extractValue,
      makeCollectionOfEquatable: makeCollectionOfEquatable,
      wrapValueIntoEquatable: wrapValueIntoEquatable,
      extractValueFromEquatable: extractValueFromEquatable,
      checksAdded: checksAdded,
      resiliencyChecks: resiliencyChecks,
      outOfBoundsIndexOffset: outOfBoundsIndexOffset)

    func makeWrappedCollection(elements: [OpaqueValue<Int>]) -> C {
      return makeCollection(elements.map(wrapValue))
    }

    testNamePrefix += String(C.Type)

    //===------------------------------------------------------------------===//
    // removeFirst()
    //===------------------------------------------------------------------===//

    self.test("\(testNamePrefix).removeFirst()/semantics") {
      for test in removeFirstTests.filter({ $0.numberToRemove == 1 }) {
        var c = makeWrappedCollection(test.collection.map(OpaqueValue.init))
        let survivingIndices =
          Array(c.startIndex.successor()..<c.endIndex)
        let removedElement = c.removeFirst()
        expectEqual(test.collection.first, extractValue(removedElement).value)
        expectEqualSequence(
          test.expectedCollection,
          c.map { extractValue($0).value },
          "removeFirst() shouldn't mutate the tail of the collection",
          stackTrace: SourceLocStack().with(test.loc)
        )
        expectEqualSequence(
          test.expectedCollection,
          survivingIndices.map { extractValue(c[$0]).value },
          "removeFirst() shouldn't invalidate indices",
          stackTrace: SourceLocStack().with(test.loc)
        )
      }
    }

    self.test("\(testNamePrefix).removeFirst()/empty/semantics") {
      var c = makeWrappedCollection(Array<OpaqueValue<Int>>())
      expectCrashLater()
      _ = c.removeFirst() // Should trap.
    }

    //===----------------------------------------------------------------------===//
    // removeFirst(n: Int)
    //===----------------------------------------------------------------------===//

    self.test("\(testNamePrefix).removeFirst(n: Int)/semantics") {
      for test in removeFirstTests {
        var c = makeWrappedCollection(test.collection.map(OpaqueValue.init))
        let survivingIndices =
          Array(
            c.startIndex.advancedBy(numericCast(test.numberToRemove)) ..<
            c.endIndex
          )
        c.removeFirst(test.numberToRemove)
        expectEqualSequence(
          test.expectedCollection,
          c.map { extractValue($0).value },
          "removeFirst() shouldn't mutate the tail of the collection",
          stackTrace: SourceLocStack().with(test.loc)
        )
        expectEqualSequence(
          test.expectedCollection,
          survivingIndices.map { extractValue(c[$0]).value },
          "removeFirst() shouldn't invalidate indices",
          stackTrace: SourceLocStack().with(test.loc)
        )
      }
    }

    self.test("\(testNamePrefix).removeFirst(n: Int)/empty/semantics") {
      var c = makeWrappedCollection(Array<OpaqueValue<Int>>())
      expectCrashLater()
      c.removeFirst(1) // Should trap.
    }

    self.test("\(testNamePrefix).removeFirst(n: Int)/removeNegative/semantics") {
      var c = makeWrappedCollection([1010, 2020].map(OpaqueValue.init))
      expectCrashLater()
      c.removeFirst(-1) // Should trap.
    }

    self.test("\(testNamePrefix).removeFirst(n: Int)/removeTooMany/semantics") {
      var c = makeWrappedCollection([1010, 2020].map(OpaqueValue.init))
      expectCrashLater()
      c.removeFirst(3) // Should trap.
    }

    //===----------------------------------------------------------------------===//

  } // addForwardRangeReplaceableSliceTests

  public func addBidirectionalRangeReplaceableSliceTests<
    C : RangeReplaceableCollection,
    CollectionWithEquatableElement : RangeReplaceableCollection
    where
    C.Index : BidirectionalIndex,
    C.SubSequence == C,
    CollectionWithEquatableElement.Index : BidirectionalIndex,
    CollectionWithEquatableElement.SubSequence == CollectionWithEquatableElement,
    CollectionWithEquatableElement.Iterator.Element : Equatable
  >(
    testNamePrefix: String = "",
    makeCollection: ([C.Iterator.Element]) -> C,
    wrapValue: (OpaqueValue<Int>) -> C.Iterator.Element,
    extractValue: (C.Iterator.Element) -> OpaqueValue<Int>,

    makeCollectionOfEquatable: ([CollectionWithEquatableElement.Iterator.Element]) -> CollectionWithEquatableElement,
    wrapValueIntoEquatable: (MinimalEquatableValue) -> CollectionWithEquatableElement.Iterator.Element,
    extractValueFromEquatable: ((CollectionWithEquatableElement.Iterator.Element) -> MinimalEquatableValue),

    checksAdded: Box<Set<String>> = Box([]),
    resiliencyChecks: CollectionMisuseResiliencyChecks = .all,
    outOfBoundsIndexOffset: Int = 1
  ) {
    var testNamePrefix = testNamePrefix

    // Don't run the same tests twice.
    if checksAdded.value.contains(#function) {
      return
    }
    checksAdded.value.insert(#function)

    addForwardRangeReplaceableSliceTests(
      testNamePrefix,
      makeCollection: makeCollection,
      wrapValue: wrapValue,
      extractValue: extractValue,
      makeCollectionOfEquatable: makeCollectionOfEquatable,
      wrapValueIntoEquatable: wrapValueIntoEquatable,
      extractValueFromEquatable: extractValueFromEquatable,
      checksAdded: checksAdded,
      resiliencyChecks: resiliencyChecks,
      outOfBoundsIndexOffset: outOfBoundsIndexOffset)

    addBidirectionalRangeReplaceableCollectionTests(
      testNamePrefix,
      makeCollection: makeCollection,
      wrapValue: wrapValue,
      extractValue: extractValue,
      makeCollectionOfEquatable: makeCollectionOfEquatable,
      wrapValueIntoEquatable: wrapValueIntoEquatable,
      extractValueFromEquatable: extractValueFromEquatable,
      checksAdded: checksAdded,
      resiliencyChecks: resiliencyChecks,
      outOfBoundsIndexOffset: outOfBoundsIndexOffset)

    func makeWrappedCollection(elements: [OpaqueValue<Int>]) -> C {
      return makeCollection(elements.map(wrapValue))
    }

    testNamePrefix += String(C.Type)

    //===------------------------------------------------------------------===//
    // removeLast()
    //===------------------------------------------------------------------===//

    self.test("\(testNamePrefix).removeLast()/semantics") {
      for test in removeLastTests.filter({ $0.numberToRemove == 1 }) {
        var c = makeWrappedCollection(test.collection)
        let survivingIndices =
          Array(c.startIndex..<c.endIndex.predecessor())
        let removedElement = c.removeLast()
        expectEqual(
          test.collection.last!.value,
          extractValue(removedElement).value)
        expectEqualSequence(
          test.expectedCollection,
          c.map { extractValue($0).value },
          "removeLast() shouldn't mutate the head of the collection",
          stackTrace: SourceLocStack().with(test.loc)
        )
        expectEqualSequence(
          test.expectedCollection,
          survivingIndices.map { extractValue(c[$0]).value },
          "removeLast() shouldn't invalidate indices",
          stackTrace: SourceLocStack().with(test.loc)
        )
      }
    }

    self.test("\(testNamePrefix).removeLast()/empty/semantics") {
      var c = makeWrappedCollection(Array<OpaqueValue<Int>>())
      expectCrashLater()
      _ = c.removeLast() // Should trap.
    }

    //===----------------------------------------------------------------------===//
    // removeLast(n: Int)
    //===----------------------------------------------------------------------===//

    self.test("\(testNamePrefix).removeLast(n: Int)/semantics") {
      for test in removeLastTests {
        var c = makeWrappedCollection(test.collection)
        let survivingIndices =
          Array(
            c.startIndex ..<
            c.endIndex.advancedBy(numericCast(-test.numberToRemove))
          )
        c.removeLast(test.numberToRemove)
        expectEqualSequence(
          test.expectedCollection,
          c.map { extractValue($0).value },
          "removeLast() shouldn't mutate the head of the collection",
          stackTrace: SourceLocStack().with(test.loc)
        )
        expectEqualSequence(
          test.expectedCollection,
          survivingIndices.map { extractValue(c[$0]).value },
          "removeLast() shouldn't invalidate indices",
          stackTrace: SourceLocStack().with(test.loc)
        )
      }
    }

    self.test("\(testNamePrefix).removeLast(n: Int)/empty/semantics") {
      var c = makeWrappedCollection(Array<OpaqueValue<Int>>())
      expectCrashLater()
      c.removeLast(1) // Should trap.
    }

    self.test("\(testNamePrefix).removeLast(n: Int)/removeNegative/semantics") {
      var c = makeWrappedCollection([1010, 2020].map(OpaqueValue.init))
      expectCrashLater()
      c.removeLast(-1) // Should trap.
    }

    self.test("\(testNamePrefix).removeLast(n: Int)/removeTooMany/semantics") {
      var c = makeWrappedCollection([1010, 2020].map(OpaqueValue.init))
      expectCrashLater()
      c.removeLast(3) // Should trap.
    }

    //===----------------------------------------------------------------------===//

  } // addBidirectionalRangeReplaceableSliceTests

  public func addRandomAccessRangeReplaceableSliceTests<
    C : RangeReplaceableCollection,
    CollectionWithEquatableElement : RangeReplaceableCollection
    where
    C.Index : RandomAccessIndex,
    C.SubSequence == C,
    CollectionWithEquatableElement.Index : RandomAccessIndex,
    CollectionWithEquatableElement.SubSequence == CollectionWithEquatableElement,
    CollectionWithEquatableElement.Iterator.Element : Equatable
  >(
    testNamePrefix: String = "",
    makeCollection: ([C.Iterator.Element]) -> C,
    wrapValue: (OpaqueValue<Int>) -> C.Iterator.Element,
    extractValue: (C.Iterator.Element) -> OpaqueValue<Int>,

    makeCollectionOfEquatable: ([CollectionWithEquatableElement.Iterator.Element]) -> CollectionWithEquatableElement,
    wrapValueIntoEquatable: (MinimalEquatableValue) -> CollectionWithEquatableElement.Iterator.Element,
    extractValueFromEquatable: ((CollectionWithEquatableElement.Iterator.Element) -> MinimalEquatableValue),

    checksAdded: Box<Set<String>> = Box([]),
    resiliencyChecks: CollectionMisuseResiliencyChecks = .all,
    outOfBoundsIndexOffset: Int = 1
  ) {
    var testNamePrefix = testNamePrefix

    // Don't run the same tests twice.
    if checksAdded.value.contains(#function) {
      return
    }
    checksAdded.value.insert(#function)

    addBidirectionalRangeReplaceableSliceTests(
      testNamePrefix,
      makeCollection: makeCollection,
      wrapValue: wrapValue,
      extractValue: extractValue,
      makeCollectionOfEquatable: makeCollectionOfEquatable,
      wrapValueIntoEquatable: wrapValueIntoEquatable,
      extractValueFromEquatable: extractValueFromEquatable,
      checksAdded: checksAdded,
      resiliencyChecks: resiliencyChecks,
      outOfBoundsIndexOffset: outOfBoundsIndexOffset)

    addRandomAccessRangeReplaceableCollectionTests(
      testNamePrefix,
      makeCollection: makeCollection,
      wrapValue: wrapValue,
      extractValue: extractValue,
      makeCollectionOfEquatable: makeCollectionOfEquatable,
      wrapValueIntoEquatable: wrapValueIntoEquatable,
      extractValueFromEquatable: extractValueFromEquatable,
      checksAdded: checksAdded,
      resiliencyChecks: resiliencyChecks,
      outOfBoundsIndexOffset: outOfBoundsIndexOffset)

    testNamePrefix += String(C.Type)

    // No tests yet.
  } // addRandomAccessRangeReplaceableCollectionTests
}
