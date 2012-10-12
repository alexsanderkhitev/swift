//===--- CFGValue.h - Value reference in the CFG ----------------*- C++ -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// This file defines the CFGValue class.
//
//===----------------------------------------------------------------------===//

#ifndef SWIFT_CFG_CFGVALUE_H
#define SWIFT_CFG_CFGVALUE_H

#include "swift/AST/Type.h"

namespace swift {
  enum class ValueKind {
#define INST(Id, Parent) Id,
#define INST_RANGE(Id, FirstId, LastId) \
First_##Id##Inst = FirstId, Last_##Id##Inst = LastId,
#include "swift/CFG/CFGNodes.def"
  };

  /// Value - This class is a value that can be used as an "operand" to an
  /// instruction.  It is either a reference to another instruction, or an
  /// incoming basic block argument.
  class Value : public CFGAllocated<Value> {
    Type Ty;
    const ValueKind Kind;
  protected:
    Value(ValueKind Kind, Type Ty) : Ty(Ty), Kind(Kind) {}
  public:

    ValueKind getKind() const { return Kind; }
    Type getType() const { return Ty; }

    /// Pretty-print the Instruction.
    void dump() const;
    void print(raw_ostream &OS) const;
  };

  typedef Value* CFGValue;
} // end namespace swift

#endif
