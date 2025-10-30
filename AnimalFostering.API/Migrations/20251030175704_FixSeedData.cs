using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace AnimalFostering.API.Migrations
{
    /// <inheritdoc />
    public partial class FixSeedData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Animals",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Animals",
                keyColumn: "Id",
                keyValue: 2);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Animals",
                columns: new[] { "Id", "Age", "Breed", "CreatedAt", "Description", "ImageUrl", "Name", "Species", "Status", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, 2, "Siamese", new DateTime(2025, 10, 30, 17, 44, 2, 455, DateTimeKind.Utc).AddTicks(2752), "Friendly and playful", "", "Whiskers", "Cat", "Available", new DateTime(2025, 10, 30, 17, 44, 2, 455, DateTimeKind.Utc).AddTicks(2756) },
                    { 2, 3, "Golden Retriever", new DateTime(2025, 10, 30, 17, 44, 2, 455, DateTimeKind.Utc).AddTicks(4624), "Loyal and energetic", "", "Buddy", "Dog", "Available", new DateTime(2025, 10, 30, 17, 44, 2, 455, DateTimeKind.Utc).AddTicks(4624) }
                });
        }
    }
}
