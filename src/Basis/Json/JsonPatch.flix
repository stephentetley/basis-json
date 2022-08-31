/*
 * Copyright 2022 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


namespace Basis/Json {

    pub enum JsonPatch(##javax.json.JsonPatch)

    // instance ToString[JsonPatch] {
    //     pub def toString(x: JsonPatch): String = Interop/Json/JsonPatch.toJsonArray(x) |> ToString.toString
    // }

}

namespace Basis/Json/JsonPatch {

    use Basis/Json.JsonPatch;
    use Basis/Json.JsonPatch.{JsonPatch};



    pub enum Operation with Eq, Order, ToString, Hash, Boxable {
        case Add
        case Copy
        case Move
        case Remove
        case Replace
        case Test
    }


    pub def marshal(x: Operation): Interop/Json/JsonPatch.Operation =
        match x {
            case Add        => Interop/Json/JsonPatch/Operation.add()
            case Copy       => Interop/Json/JsonPatch/Operation.copy()
            case Move       => Interop/Json/JsonPatch/Operation.move()
            case Remove     => Interop/Json/JsonPatch/Operation.remove()
            case Replace    => Interop/Json/JsonPatch/Operation.replace()
            case Test       => Interop/Json/JsonPatch/Operation.test()
        }

    def primEquals(x: Interop/Json/JsonPatch.Operation, y: Interop/Json/JsonPatch.Operation): Bool =
        Interop/Lang/Enum.equals(Interop/Lang/SubEnum.toEnum(x), Interop/Lang/SubEnum.toEnum(y))


    pub def unmarshal(x: Interop/Json/JsonPatch.Operation): Operation = 
        match x {
            case x1 if primEquals(x1, Interop/Json/JsonPatch/Operation.add())       => Add
            case x1 if primEquals(x1, Interop/Json/JsonPatch/Operation.copy())      => Copy
            case x1 if primEquals(x1, Interop/Json/JsonPatch/Operation.move())      => Move
            case x1 if primEquals(x1, Interop/Json/JsonPatch/Operation.remove())    => Remove
            case x1 if primEquals(x1, Interop/Json/JsonPatch/Operation.replace())   => Replace
            case x1 if primEquals(x1, Interop/Json/JsonPatch/Operation.test())      => Test
        }

    // pub def toJsonArray(x: JsonPatch): JsonArray =
    //     import javax.json.JsonPatch.toJsonArray(): ##javax.json.JsonArray & Pure;
    //     let JsonPatch(x1) = x;
    //     JsonArray(toJsonArray(x1))

    // pub def createJsonObjectDiff(src: JsonObject, dst: JsonObject): JsonPatch = 
    //     import static javax.json.Json.createDiff(##javax.json.JsonStructure, ##javax.json.JsonStructure): ##javax.json.JsonPatch & Pure;
    //     let JsonObject(src1) = src;
    //     let JsonObject(dst1) = dst;
    //     JsonPatch(createDiff(src1 as ##javax.json.JsonStructure, dst1 as ##javax.json.JsonStructure))

    // pub def createJsonArrayDiff(src: JsonArray, dst: JsonArray): JsonPatch = 
    //     import static javax.json.Json.createDiff(##javax.json.JsonStructure, ##javax.json.JsonStructure): ##javax.json.JsonPatch & Pure;
    //     let JsonArray(src1) = src;
    //     let JsonArray(dst1) = dst;
    //     JsonPatch(createDiff(src1 as ##javax.json.JsonStructure, dst1 as ##javax.json.JsonStructure))


    // pub def applyToJsonObject(x: JsonPatch, o: JsonObject): Result[JsonObject, String] =
    //     import javax.json.JsonPatch.apply(##javax.json.JsonStructure): ##javax.json.JsonStructure & Pure;
    //     try {
    //         let JsonPatch(x1) = x;
    //         let JsonObject(o1) = o;
    //         let ans = apply(x1, o1 as ##javax.json.JsonStructure);
    //         JsonObject(ans as ##javax.json.JsonObject) |> Ok
    //     } catch {
    //         case ex: ##java.lang.Exception => {
    //             import java.lang.Throwable.getMessage(): String & Pure;
    //             Err(getMessage(ex as ##java.lang.Throwable))
    //         }
    //     }

    // pub def applyToJsonArray(x: JsonPatch, arr: JsonArray): Result[JsonArray, String] =
    //     import javax.json.JsonPatch.apply(##javax.json.JsonStructure): ##javax.json.JsonStructure & Pure;
    //     try {
    //         let JsonPatch(x1) = x;
    //         let JsonArray(arr1) = arr;
    //         let ans = apply(x1, arr1 as ##javax.json.JsonStructure);
    //         JsonArray(ans as ##javax.json.JsonArray) |> Ok
    //     } catch {
    //         case ex: ##java.lang.Exception => {
    //             import java.lang.Throwable.getMessage(): String & Pure;
    //             Err(getMessage(ex as ##java.lang.Throwable))
    //         }
    //     }

}
