return function()
    local module = Deus:Load("Deus.Output")

    describe("print", function()
        it("should never throw", function()
            expect(function()
                module.print()
            end).to.never.throw()
        end)
    end)

    describe("warn", function()
        it("should never throw", function()
            expect(function()
                module.warn()
            end).to.never.throw()
        end)
    end)

    describe("error", function()
        it("should throw", function()
            expect(function()
                module.error()
            end).to.throw()
        end)
    end)

    describe("assert", function()
        it("with nil should throw", function()
            expect(function()
                module.assert()
            end).to.throw()
        end)

        it("with false should throw", function()
            expect(function()
                module.assert(false)
            end).to.throw()
        end)

        it("with true should do nothing", function()
            expect(function()
                module.assert(true)
            end).to.never.throw()
        end)
    end)
end